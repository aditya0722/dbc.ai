import 'package:supabase_flutter/supabase_flutter.dart';

class DataMigrationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all migration projects for current user
  Future<List<Map<String, dynamic>>> getMigrationProjects() async {
    try {
      final response = await _supabase
          .from('migration_projects')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch migration projects: $e');
    }
  }

  // Get single migration project with details
  Future<Map<String, dynamic>> getMigrationProject(String projectId) async {
    try {
      final response = await _supabase
          .from('migration_projects')
          .select('*')
          .eq('id', projectId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch migration project: $e');
    }
  }

  // Create new migration project
  Future<Map<String, dynamic>> createMigrationProject({
    required String projectName,
    required String sourceType,
    required List<String> targetModules,
    Map<String, dynamic>? sourceConfig,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('migration_projects')
          .insert({
            'user_id': userId,
            'project_name': projectName,
            'source_type': sourceType,
            'target_modules': targetModules,
            'source_config': sourceConfig,
            'status': 'draft',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to create migration project: $e');
    }
  }

  // Update migration project status
  Future<void> updateMigrationStatus(String projectId, String status) async {
    try {
      await _supabase.from('migration_projects').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to update migration status: $e');
    }
  }

  // Get field mappings for project
  Future<List<Map<String, dynamic>>> getFieldMappings(String projectId) async {
    try {
      final response = await _supabase
          .from('field_mappings')
          .select('*')
          .eq('migration_project_id', projectId)
          .order('target_table');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch field mappings: $e');
    }
  }

  // Create field mapping
  Future<void> createFieldMapping({
    required String projectId,
    required String sourceField,
    required String targetField,
    required String targetTable,
    required String mappingType,
    bool isRequired = false,
    String? defaultValue,
  }) async {
    try {
      await _supabase.from('field_mappings').insert({
        'migration_project_id': projectId,
        'source_field': sourceField,
        'target_field': targetField,
        'target_table': targetTable,
        'mapping_type': mappingType,
        'is_required': isRequired,
        'default_value': defaultValue,
      });
    } catch (e) {
      throw Exception('Failed to create field mapping: $e');
    }
  }

  // Delete field mapping
  Future<void> deleteFieldMapping(String mappingId) async {
    try {
      await _supabase.from('field_mappings').delete().eq('id', mappingId);
    } catch (e) {
      throw Exception('Failed to delete field mapping: $e');
    }
  }

  // Get migration templates
  Future<List<Map<String, dynamic>>> getMigrationTemplates({
    String? sourceType,
  }) async {
    try {
      var query = _supabase.from('migration_templates').select('*');

      if (sourceType != null) {
        query = query.eq('source_type', sourceType);
      }

      final response = await query.order('usage_count', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch migration templates: $e');
    }
  }

  // Save migration as template
  Future<Map<String, dynamic>> saveMigrationTemplate({
    required String templateName,
    required String sourceType,
    required List<String> targetModules,
    required Map<String, dynamic> fieldMappings,
    bool isPublic = false,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('migration_templates')
          .insert({
            'user_id': userId,
            'template_name': templateName,
            'source_type': sourceType,
            'target_modules': targetModules,
            'field_mappings': fieldMappings,
            'is_public': isPublic,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to save migration template: $e');
    }
  }

  // Get migration logs
  Future<List<Map<String, dynamic>>> getMigrationLogs(String projectId,
      {String? severity}) async {
    try {
      var query = _supabase
          .from('migration_logs')
          .select('*')
          .eq('migration_project_id', projectId);

      if (severity != null) {
        query = query.eq('severity', severity);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch migration logs: $e');
    }
  }

  // Calculate migration progress
  Future<Map<String, dynamic>> calculateProgress(String projectId) async {
    try {
      final response = await _supabase.rpc('calculate_migration_progress',
          params: {'project_uuid': projectId});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to calculate migration progress: $e');
    }
  }

  // Validate migration data
  Future<Map<String, dynamic>> validateMigrationData(String projectId) async {
    try {
      final response = await _supabase.rpc('validate_migration_data',
          params: {'project_uuid': projectId}).select();

      if (response.isNotEmpty) {
        return response[0];
      }
      return {
        'validation_status': 'unknown',
        'error_count': 0,
        'warning_count': 0,
        'errors': []
      };
    } catch (e) {
      throw Exception('Failed to validate migration data: $e');
    }
  }

  // Start migration import
  Future<void> startMigrationImport(String projectId) async {
    try {
      await _supabase.from('migration_projects').update({
        'status': 'importing',
        'started_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to start migration import: $e');
    }
  }

  // Complete migration import
  Future<void> completeMigrationImport(String projectId) async {
    try {
      await _supabase.from('migration_projects').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to complete migration import: $e');
    }
  }

  // Pause migration
  Future<void> pauseMigration(String projectId) async {
    try {
      await _supabase
          .from('migration_projects')
          .update({'status': 'paused'}).eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to pause migration: $e');
    }
  }

  // Resume migration
  Future<void> resumeMigration(String projectId) async {
    try {
      await _supabase
          .from('migration_projects')
          .update({'status': 'importing'}).eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to resume migration: $e');
    }
  }

  // Delete migration project
  Future<void> deleteMigrationProject(String projectId) async {
    try {
      await _supabase.from('migration_projects').delete().eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to delete migration project: $e');
    }
  }
}
