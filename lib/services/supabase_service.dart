import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._internal();
  
  SupabaseService._internal();
  
  // Supabase configuration - Replace with your actual Supabase URL and anon key
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  
  // Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }
  
  // Authentication methods
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      debugPrint('User signed up: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }
  
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('User signed in: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      debugPrint('User signed out');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }
  
  // Layout/Preset database operations
  Future<List<Map<String, dynamic>>> getUserLayouts() async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    
    try {
      final response = await client
          .from('user_layouts')
          .select()
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching user layouts: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> saveLayout(String name, Map<String, dynamic> layoutData) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    
    try {
      final response = await client
          .from('user_layouts')
          .insert({
            'user_id': currentUser!.id,
            'name': name,
            'layout_data': layoutData,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      debugPrint('Layout saved: $name');
      return response;
    } catch (e) {
      debugPrint('Error saving layout: $e');
      rethrow;
    }
  }
  
  Future<void> updateLayout(int layoutId, String name, Map<String, dynamic> layoutData) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    
    try {
      await client
          .from('user_layouts')
          .update({
            'name': name,
            'layout_data': layoutData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', layoutId)
          .eq('user_id', currentUser!.id);
      
      debugPrint('Layout updated: $name');
    } catch (e) {
      debugPrint('Error updating layout: $e');
      rethrow;
    }
  }
  
  Future<void> deleteLayout(int layoutId) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    
    try {
      await client
          .from('user_layouts')
          .delete()
          .eq('id', layoutId)
          .eq('user_id', currentUser!.id);
      
      debugPrint('Layout deleted: $layoutId');
    } catch (e) {
      debugPrint('Error deleting layout: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>?> getLayoutByName(String name) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    
    try {
      final response = await client
          .from('user_layouts')
          .select()
          .eq('user_id', currentUser!.id)
          .eq('name', name)
          .maybeSingle();
      
      return response;
    } catch (e) {
      debugPrint('Error fetching layout by name: $e');
      rethrow;
    }
  }
  
  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}