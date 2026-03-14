import '../services/supabase_service.dart';

/// Service class for managing job positions and applications
/// Provides CRUD operations and business logic for hiring features
class HiringService {
  final client = SupabaseService.instance.client;

  /// Fetches all active job positions
  /// Returns list of job positions with full details
  Future<List<Map<String, dynamic>>> getActiveJobPositions() async {
    try {
      final response = await client
          .from('job_positions')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch job positions: $error');
    }
  }

  /// Fetches job positions by department
  /// @param department - Department name to filter by
  Future<List<Map<String, dynamic>>> getJobPositionsByDepartment(
      String department) async {
    try {
      final response = await client
          .from('job_positions')
          .select()
          .eq('department', department)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch positions by department: $error');
    }
  }

  /// Creates a new job position
  /// @param positionData - Map containing job position details
  Future<Map<String, dynamic>> createJobPosition(
      Map<String, dynamic> positionData) async {
    try {
      final response =
          await client.from('job_positions').insert(positionData).select();
      return response.first;
    } catch (error) {
      throw Exception('Failed to create job position: $error');
    }
  }

  /// Updates an existing job position
  /// @param positionId - UUID of the position to update
  /// @param updates - Map of fields to update
  Future<Map<String, dynamic>> updateJobPosition(
      String positionId, Map<String, dynamic> updates) async {
    try {
      final response = await client
          .from('job_positions')
          .update(updates)
          .eq('id', positionId)
          .select();
      return response.first;
    } catch (error) {
      throw Exception('Failed to update job position: $error');
    }
  }

  /// Fetches all applications for a specific job position
  /// @param jobPositionId - UUID of the job position
  Future<List<Map<String, dynamic>>> getApplicationsByPosition(
      String jobPositionId) async {
    try {
      final response = await client
          .from('job_applications')
          .select()
          .eq('job_position_id', jobPositionId)
          .order('applied_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch applications: $error');
    }
  }

  /// Fetches applications filtered by status
  /// @param status - Application status to filter by
  Future<List<Map<String, dynamic>>> getApplicationsByStatus(
      String status) async {
    try {
      final response = await client
          .from('job_applications')
          .select('*, job_positions(*)')
          .eq('status', status)
          .order('applied_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch applications by status: $error');
    }
  }

  /// Creates a new job application
  /// @param applicationData - Map containing application details
  Future<Map<String, dynamic>> createApplication(
      Map<String, dynamic> applicationData) async {
    try {
      final response = await client
          .from('job_applications')
          .insert(applicationData)
          .select();
      return response.first;
    } catch (error) {
      throw Exception('Failed to create application: $error');
    }
  }

  /// Updates application status
  /// @param applicationId - UUID of the application
  /// @param status - New status value
  /// @param reviewerId - UUID of the reviewer (optional)
  /// @param notes - Review notes (optional)
  Future<Map<String, dynamic>> updateApplicationStatus(
    String applicationId,
    String status, {
    String? reviewerId,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (reviewerId != null) {
        updates['reviewed_by'] = reviewerId;
        updates['reviewed_at'] = DateTime.now().toIso8601String();
      }

      if (notes != null) {
        updates['notes'] = notes;
      }

      final response = await client
          .from('job_applications')
          .update(updates)
          .eq('id', applicationId)
          .select();
      return response.first;
    } catch (error) {
      throw Exception('Failed to update application status: $error');
    }
  }

  /// Schedules an interview for an application
  /// @param scheduleData - Map containing interview schedule details
  Future<Map<String, dynamic>> scheduleInterview(
      Map<String, dynamic> scheduleData) async {
    try {
      final response = await client
          .from('interview_schedules')
          .insert(scheduleData)
          .select();
      return response.first;
    } catch (error) {
      throw Exception('Failed to schedule interview: $error');
    }
  }

  /// Fetches interview schedules for an application
  /// @param applicationId - UUID of the application
  Future<List<Map<String, dynamic>>> getInterviewSchedules(
      String applicationId) async {
    try {
      final response = await client
          .from('interview_schedules')
          .select('*, user_profiles!interviewer_id(*)')
          .eq('application_id', applicationId)
          .order('interview_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch interview schedules: $error');
    }
  }

  /// Gets count of applications grouped by status
  Future<Map<String, int>> getApplicationStatusCounts() async {
    try {
      final pendingData = await client
          .from('job_applications')
          .select('id')
          .eq('status', 'pending')
          .count();

      final reviewingData = await client
          .from('job_applications')
          .select('id')
          .eq('status', 'reviewing')
          .count();

      final shortlistedData = await client
          .from('job_applications')
          .select('id')
          .eq('status', 'shortlisted')
          .count();

      return {
        'pending': pendingData.count,
        'reviewing': reviewingData.count,
        'shortlisted': shortlistedData.count,
      };
    } catch (error) {
      throw Exception('Failed to fetch status counts: $error');
    }
  }

  /// Gets count of active job positions
  Future<int> getActivePositionsCount() async {
    try {
      final response = await client
          .from('job_positions')
          .select('id')
          .eq('is_active', true)
          .count();
      return response.count;
    } catch (error) {
      throw Exception('Failed to fetch active positions count: $error');
    }
  }

  /// Searches applications by candidate name or email
  /// @param searchQuery - Search text
  Future<List<Map<String, dynamic>>> searchApplications(
      String searchQuery) async {
    try {
      final response = await client
          .from('job_applications')
          .select('*, job_positions(*)')
          .or('candidate_name.ilike.%$searchQuery%,candidate_email.ilike.%$searchQuery%')
          .order('applied_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search applications: $error');
    }
  }

  /// Deletes a job position
  /// @param positionId - UUID of the position to delete
  Future<void> deleteJobPosition(String positionId) async {
    try {
      await client.from('job_positions').delete().eq('id', positionId);
    } catch (error) {
      throw Exception('Failed to delete job position: $error');
    }
  }
}
