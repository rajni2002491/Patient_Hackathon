import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class PatientProfileScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientProfileScreen({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<PatientProfileScreen> createState() =>
      _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  // Patient data
  String patientName = 'Sarah Johnson';
  int age = 42;
  String gender = 'Female';
  String bloodType = 'A+';
  String allergies = 'Penicillin, Peanuts';
  String chronicConditions = 'Type 2 Diabetes, Hypertension';
  String medications = 'Metformin 500mg, Lisinopril 10mg';
  String lastVisit = '2024-03-15';
  String nextAppointment = '2024-04-20';
  String primaryDoctor = 'Dr. Michael Chen';
  String address = '123 Medical Center Dr, Suite 456';
  String phone = '(555) 123-4567';
  String email = 'sarah.johnson@email.com';
  String emergencyContact = 'John Johnson (Husband)';
  String emergencyPhone = '(555) 987-6543';

  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _lastVisitController = TextEditingController();
  final TextEditingController _nextAppointmentController =
      TextEditingController();
  final TextEditingController _primaryDoctorController =
      TextEditingController();

  bool _isEditing = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = patientName;
    _ageController.text = age.toString();
    _genderController.text = gender;
    _bloodTypeController.text = bloodType;
    _allergiesController.text = allergies;
    _conditionsController.text = chronicConditions;
    _medicationsController.text = medications;
    _addressController.text = address;
    _phoneController.text = phone;
    _emailController.text = email;
    _emergencyContactController.text = emergencyContact;
    _emergencyPhoneController.text = emergencyPhone;
    _lastVisitController.text = lastVisit;
    _nextAppointmentController.text = nextAppointment;
    _primaryDoctorController.text = primaryDoctor;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save the changes
        _saveChanges();
      }
    });
  }

  void _saveChanges() {
    setState(() {
      patientName = _nameController.text;
      age = int.tryParse(_ageController.text) ?? age;
      gender = _genderController.text;
      bloodType = _bloodTypeController.text;
      allergies = _allergiesController.text;
      chronicConditions = _conditionsController.text;
      medications = _medicationsController.text;
      address = _addressController.text;
      phone = _phoneController.text;
      email = _emailController.text;
      emergencyContact = _emergencyContactController.text;
      emergencyPhone = _emergencyPhoneController.text;
      lastVisit = _lastVisitController.text;
      nextAppointment = _nextAppointmentController.text;
      primaryDoctor = _primaryDoctorController.text;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _lastVisitController.dispose();
    _nextAppointmentController.dispose();
    _primaryDoctorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Patient Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              // height: 200,
               width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [
                          const Color(0xFF1E1E1E),
                          const Color(0xFF121212),
                        ]
                      : [
                          const Color(0xFF2196F3),
                          const Color(0xFF1976D2),
                        ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/profile_photos/patient.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.blue,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patient ID: ${widget.patientId}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information'),
                  _buildInfoCard(
                    children: [
                      _buildInfoRow('Name', _nameController, _isEditing),
                      _buildInfoRow('Age', _ageController, _isEditing),
                      _buildInfoRow('Gender', _genderController, _isEditing),
                      _buildInfoRow(
                          'Blood Type', _bloodTypeController, _isEditing),
                      _buildInfoRow('Address', _addressController, _isEditing),
                      _buildInfoRow('Phone', _phoneController, _isEditing),
                      _buildInfoRow('Email', _emailController, _isEditing),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Medical Information'),
                  _buildInfoCard(
                    children: [
                      _buildInfoRow(
                          'Allergies', _allergiesController, _isEditing),
                      _buildInfoRow('Chronic Conditions', _conditionsController,
                          _isEditing),
                      _buildInfoRow('Current Medications',
                          _medicationsController, _isEditing),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Emergency Contact'),
                  _buildInfoCard(
                    children: [
                      _buildInfoRow('Contact Name', _emergencyContactController,
                          _isEditing),
                      _buildInfoRow('Contact Phone', _emergencyPhoneController,
                          _isEditing),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Appointments'),
                  _buildInfoCard(
                    children: [
                      _buildInfoRow(
                          'Last Visit', _lastVisitController, _isEditing),
                      _buildInfoRow('Next Appointment',
                          _nextAppointmentController, _isEditing),
                      _buildInfoRow('Primary Doctor', _primaryDoctorController,
                          _isEditing),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, TextEditingController controller, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  )
                : Text(controller.text),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isEditing ? _toggleEdit : null,
            icon: const Icon(Icons.edit),
            label: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement share profile
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
