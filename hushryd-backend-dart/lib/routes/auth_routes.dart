import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';
import '../config/env.dart';
import '../config/database.dart';
import '../models/user.dart';
import '../models/admin.dart';
import '../middleware/auth_middleware.dart';
import '../utils/response.dart';
import '../utils/validators.dart';

class AuthRoutes {
  final _uuid = const Uuid();

  Router get router {
    final router = Router();

    // POST /register
    router.post('/register', _register);
    // POST /login
    router.post('/login', _login);
    // POST /admin/login
    router.post('/admin/login', _adminLogin);
    // POST /admin/create
    router.post('/admin/create', _adminCreate);
    // GET /verify
    router.get('/verify', Pipeline()
        .addMiddleware(authenticateToken())
        .addHandler(_verify));
    // PUT /change-password
    router.put('/change-password', Pipeline()
        .addMiddleware(authenticateToken())
        .addHandler(_changePassword));
    // POST /logout
    router.post('/logout', _logout);
    // GET /logout
    router.get('/logout', _logout);
    // POST /send-otp
    router.post('/send-otp', _sendOtp);
    // POST /verify-otp
    router.post('/verify-otp', _verifyOtp);
    // GET /profile
    router.get('/profile', Pipeline()
        .addMiddleware(authenticateToken())
        .addHandler(_getProfile));

    return router;
  }

  String _generateToken(Map<String, dynamic> payload) {
    final jwt = JWT(payload);
    return jwt.sign(SecretKey(Env.jwtSecret), expiresIn: Duration(hours: 24));
  }

  Future<Response> _register(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final missing = Validators.validateRequired(
          body, ['email', 'password', 'firstName', 'lastName', 'phone']);
      if (missing != null) return ApiResponse.badRequest(missing);

      final email = body['email'] as String;
      if (!Validators.isValidEmail(email)) {
        return ApiResponse.badRequest('Invalid email format');
      }

      // Check existing user
      final existing = await User.findByEmail(email);
      if (existing != null) {
        return ApiResponse.conflict('User with this email already exists');
      }

      final hashedPassword =
          BCrypt.hashpw(body['password'] as String, BCrypt.gensalt());

      // Store password in a separate auth table or the users table
      final userId = _uuid.v4();
      await Database.query(
        '''INSERT INTO users (id, email, first_name, last_name, phone, is_verified, is_active, role)
           VALUES (@id, @email, @firstName, @lastName, @phone, false, true, 'user')''',
        parameters: {
          'id': userId,
          'email': email,
          'firstName': Validators.sanitize(body['firstName'] as String),
          'lastName': Validators.sanitize(body['lastName'] as String),
          'phone': body['phone'] as String,
        },
      );

      // Store password
      await Database.query(
        '''INSERT INTO user_passwords (user_id, password_hash)
           VALUES (@userId, @hash)
           ON CONFLICT (user_id) DO UPDATE SET password_hash = @hash''',
        parameters: {'userId': userId, 'hash': hashedPassword},
      );

      final user = await User.findById(userId);
      final token = _generateToken({
        'id': userId,
        'email': email,
        'role': 'user',
      });

      return ApiResponse.created('User registered successfully', data: {
        'user': user?.toJson(),
        'token': token,
      });
    } catch (e) {
      print('Register error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _login(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final missing =
          Validators.validateRequired(body, ['email', 'password']);
      if (missing != null) return ApiResponse.badRequest(missing);

      final email = body['email'] as String;
      final user = await User.findByEmail(email);
      if (user == null) {
        return ApiResponse.unauthorized('Invalid email or password');
      }

      // Get password hash
      final passResult = await Database.query(
        'SELECT password_hash FROM user_passwords WHERE user_id = @id',
        parameters: {'id': user.id},
      );
      if (passResult.isEmpty) {
        return ApiResponse.unauthorized('Invalid email or password');
      }

      final hash = passResult.first.toColumnMap()['password_hash'] as String;
      if (!BCrypt.checkpw(body['password'] as String, hash)) {
        return ApiResponse.unauthorized('Invalid email or password');
      }

      final token = _generateToken({
        'id': user.id,
        'email': user.email,
        'role': user.role,
      });

      return ApiResponse.success('Login successful', data: {
        'user': user.toJson(),
        'token': token,
      });
    } catch (e) {
      print('Login error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _adminLogin(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final missing =
          Validators.validateRequired(body, ['email', 'password']);
      if (missing != null) return ApiResponse.badRequest(missing);

      final email = body['email'] as String;
      final admin = await Admin.findByEmail(email);
      if (admin == null) {
        return ApiResponse.unauthorized('Invalid email or password');
      }

      if (!admin.isActive) {
        return ApiResponse.unauthorized('Account is deactivated');
      }

      if (admin.password == null ||
          !BCrypt.checkpw(body['password'] as String, admin.password!)) {
        return ApiResponse.unauthorized('Invalid email or password');
      }

      // Update last login
      await Database.query(
        'UPDATE admins SET last_login = CURRENT_TIMESTAMP WHERE id = @id',
        parameters: {'id': admin.id},
      );

      final token = _generateToken({
        'id': admin.id,
        'email': admin.email,
        'role': admin.role,
        'adminId': admin.id,
      });

      return ApiResponse.success('Admin login successful', data: {
        'admin': admin.toJson(),
        'token': token,
      });
    } catch (e) {
      print('Admin login error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _adminCreate(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final missing = Validators.validateRequired(
          body, ['email', 'password', 'firstName', 'lastName']);
      if (missing != null) return ApiResponse.badRequest(missing);

      final email = body['email'] as String;
      final existing = await Admin.findByEmail(email);
      if (existing != null) {
        return ApiResponse.conflict('Admin with this email already exists');
      }

      final hashedPassword =
          BCrypt.hashpw(body['password'] as String, BCrypt.gensalt());

      final admin = await Admin.create({
        'id': _uuid.v4(),
        'email': email,
        'password': hashedPassword,
        'firstName': Validators.sanitize(body['firstName'] as String),
        'lastName': Validators.sanitize(body['lastName'] as String),
        'role': body['role'] ?? 'admin',
        'permissions': body['permissions'] ?? [],
        'isActive': true,
      });

      final token = _generateToken({
        'id': admin.id,
        'email': admin.email,
        'role': admin.role,
        'adminId': admin.id,
      });

      return ApiResponse.created('Admin created successfully', data: {
        'admin': admin.toJson(),
        'token': token,
      });
    } catch (e) {
      print('Admin create error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _verify(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final role = request.context['userRole'] as String;

      if (role == 'admin' || role == 'superadmin') {
        final admin = await Admin.findById(userId);
        if (admin == null) return ApiResponse.unauthorized('Admin not found');
        return ApiResponse.success('Token is valid', data: {
          'admin': admin.toJson(),
          'role': role,
        });
      }

      final user = await User.findById(userId);
      if (user == null) return ApiResponse.unauthorized('User not found');
      return ApiResponse.success('Token is valid', data: {
        'user': user.toJson(),
        'role': role,
      });
    } catch (e) {
      print('Verify error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _changePassword(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final missing = Validators.validateRequired(
          body, ['currentPassword', 'newPassword']);
      if (missing != null) return ApiResponse.badRequest(missing);

      final userId = request.context['userId'] as String;
      final role = request.context['userRole'] as String;

      if (role == 'admin' || role == 'superadmin') {
        final admin = await Admin.findById(userId);
        if (admin == null) return ApiResponse.notFound('Admin not found');
        if (admin.password == null ||
            !BCrypt.checkpw(body['currentPassword'] as String, admin.password!)) {
          return ApiResponse.unauthorized('Current password is incorrect');
        }
        final newHash =
            BCrypt.hashpw(body['newPassword'] as String, BCrypt.gensalt());
        await Database.query(
          'UPDATE admins SET password = @hash, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
          parameters: {'hash': newHash, 'id': userId},
        );
      } else {
        final passResult = await Database.query(
          'SELECT password_hash FROM user_passwords WHERE user_id = @id',
          parameters: {'id': userId},
        );
        if (passResult.isEmpty) {
          return ApiResponse.unauthorized('User not found');
        }
        final hash =
            passResult.first.toColumnMap()['password_hash'] as String;
        if (!BCrypt.checkpw(body['currentPassword'] as String, hash)) {
          return ApiResponse.unauthorized('Current password is incorrect');
        }
        final newHash =
            BCrypt.hashpw(body['newPassword'] as String, BCrypt.gensalt());
        await Database.query(
          'UPDATE user_passwords SET password_hash = @hash WHERE user_id = @id',
          parameters: {'hash': newHash, 'id': userId},
        );
      }

      return ApiResponse.success('Password changed successfully');
    } catch (e) {
      print('Change password error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _logout(Request request) async {
    return ApiResponse.success('Logged out successfully');
  }

  // In-memory OTP store (in production, use Redis or DB)
  static final _otpStore = <String, String>{};

  Future<Response> _sendOtp(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final phone = body['phone'] as String?;
      if (phone == null || phone.isEmpty) {
        return ApiResponse.badRequest('Phone number is required');
      }

      final otp = (Random().nextInt(9000) + 1000).toString();
      _otpStore[phone] = otp;
      print('OTP for $phone: $otp'); // In production, send via SMS gateway

      return ApiResponse.success('OTP sent successfully', data: {
        'message': 'OTP has been sent to your phone',
      });
    } catch (e) {
      print('Send OTP error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _verifyOtp(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final phone = body['phone'] as String?;
      final otp = body['otp'] as String?;
      if (phone == null || otp == null) {
        return ApiResponse.badRequest('Phone and OTP are required');
      }

      final storedOtp = _otpStore[phone];
      if (storedOtp == null || storedOtp != otp) {
        return ApiResponse.unauthorized('Invalid OTP');
      }
      _otpStore.remove(phone);

      // Find or create user by phone
      final result = await Database.query(
        'SELECT * FROM users WHERE phone = @phone',
        parameters: {'phone': phone},
      );

      String userId;
      if (result.isEmpty) {
        userId = _uuid.v4();
        await Database.query(
          '''INSERT INTO users (id, phone, is_verified, is_active, role)
             VALUES (@id, @phone, true, true, 'user')''',
          parameters: {'id': userId, 'phone': phone},
        );
      } else {
        userId = result.first.toColumnMap()['id'] as String;
      }

      final user = await User.findById(userId);
      final token = _generateToken({
        'id': userId,
        'phone': phone,
        'role': user?.role ?? 'user',
      });

      return ApiResponse.success('OTP verified successfully', data: {
        'user': user?.toJson(),
        'token': token,
      });
    } catch (e) {
      print('Verify OTP error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getProfile(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final user = await User.findById(userId);
      if (user == null) return ApiResponse.notFound('User not found');

      return ApiResponse.success('Profile retrieved successfully', data: {
        'user': user.toJson(),
      });
    } catch (e) {
      print('Get profile error: $e');
      return ApiResponse.error('Internal server error');
    }
  }
}
