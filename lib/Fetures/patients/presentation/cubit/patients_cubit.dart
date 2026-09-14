import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hive/hive.dart';
import '../../data/model/patient_model.dart';
import 'patients_state.dart';
import '../../../Auth/data/local/auth_local_storage.dart';

class PatientsCubit extends Cubit<PatientsState> {
  // final Box<PatientModel> _patientsBox;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _patientsSubscription;

  // PatientsCubit(this._patientsBox) : super(PatientsInitial());
  PatientsCubit() : super(PatientsInitial());

  String? _getUid() {
    return AuthLocalStorage.getUser()?.uid;
  }

  void loadPatients() {
    emit(PatientsLoading());
    final uid = _getUid();
    
    if (uid == null) {
      emit(PatientsError("User not logged in"));
      return;
    }

    try {
      _patientsSubscription?.cancel();
      _patientsSubscription = _firestore
          .collection('users')
          .doc(uid)
          .collection('patients')
          .snapshots()
          .listen((snapshot) async {
        
        const meId = 'user_1';
        List<PatientModel> patients = snapshot.docs.map((doc) {
          final data = doc.data();
          // We assume fromMap / toMap methods or similar exist, but PatientModel has a fromJson.
          // Let's create from the fields manually or use json.
          // Wait, PatientModel in Hive might not have fromJson. Let's check PatientModel.
          // I will use PatientModel's standard constructor for now.
          return PatientModel(
            id: data['id'] ?? doc.id,
            name: data['name'] ?? '',
            relationship: data['relationship'] ?? '',
          );
        }).toList();

        // Ensure "Me" exists in the data
        bool meExists = patients.any((p) => p.id == meId);
        if (!meExists) {
          final me = PatientModel(id: meId, name: 'أنا', relationship: 'نفسي');
          // Save it to firestore
          await _firestore.collection('users').doc(uid).collection('patients').doc(meId).set({
            'id': me.id,
            'name': me.name,
            'relationship': me.relationship,
          });
          patients.add(me);
        }

        // Sort so "Me" is first
        patients.sort((a, b) {
          if (a.id == meId) return -1;
          if (b.id == meId) return 1;
          return 0;
        });

        // Determine selected patient
        String? selectedId = meId;
        if (state is PatientsLoaded) {
          final currentSelected = (state as PatientsLoaded).selectedPatientId;
          if (patients.any((p) => p.id == currentSelected)) {
            selectedId = currentSelected;
          }
        }

        emit(PatientsLoaded(
          patients: patients,
          selectedPatientId: selectedId,
        ));
      }, onError: (e) {
        emit(PatientsError("Failed to load patients: $e"));
      });
      
    } catch (e) {
      emit(PatientsError("Failed to load patients: $e"));
    }
  }

  void addPatient(PatientModel patient) async {
    final uid = _getUid();
    if (uid == null) return;
    
    try {
      // await _patientsBox.put(patient.id, patient);
      await _firestore.collection('users').doc(uid).collection('patients').doc(patient.id).set({
        'id': patient.id,
        'name': patient.name,
        'relationship': patient.relationship,
      });

      // Selection logic is handled via snapshot listener, but we can optimistically set selected patient
      final currentState = state;
      if (currentState is PatientsLoaded) {
        emit(PatientsLoaded(
          patients: currentState.patients,
          selectedPatientId: patient.id,
        ));
      }
    } catch (e) {
      emit(PatientsError("Failed to add patient: $e"));
    }
  }

  void selectPatient(String? patientId) {
    final currentState = state;
    if (currentState is PatientsLoaded) {
      emit(PatientsLoaded(
        patients: currentState.patients,
        selectedPatientId: patientId,
      ));
    }
  }

  @override
  Future<void> close() {
    _patientsSubscription?.cancel();
    return super.close();
  }
}
