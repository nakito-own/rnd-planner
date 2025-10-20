import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/employee_model.dart';
import '../../data/models/robot_model.dart';
import '../../data/models/transport_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
  static Future<List<Employee>> getEmployees({
    int skip = 0,
    int limit = 100,
    String? body,
    int? crewId,
    bool? parking,
    bool? drive,
    bool? telemedicine,
    bool? accessToAutoVc,
  }) async {
    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      
      if (body != null && body.isNotEmpty) {
        queryParams['body'] = body;
      }
      if (crewId != null) {
        queryParams['crew_id'] = crewId.toString();
      }
      if (parking != null) {
        queryParams['parking'] = parking.toString();
      }
      if (drive != null) {
        queryParams['drive'] = drive.toString();
      }
      if (telemedicine != null) {
        queryParams['telemedicine'] = telemedicine.toString();
      }
      if (accessToAutoVc != null) {
        queryParams['access_to_auto_vc'] = accessToAutoVc.toString();
      }

      final uri = Uri.parse('$baseUrl/crews/employees').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading employees: $e');
    }
  }

  static Future<Employee> getEmployee(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/crews/employees/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Employee.fromJson(json);
      } else {
        throw Exception('Failed to load employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading employee: $e');
    }
  }

  static Future<Employee> createEmployee(Map<String, dynamic> employeeData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/crews/employees'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(employeeData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Employee.fromJson(json);
      } else {
        throw Exception('Failed to create employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating employee: $e');
    }
  }

  static Future<Employee> updateEmployee(int id, Map<String, dynamic> employeeData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/crews/employees/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(employeeData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Employee.fromJson(json);
      } else {
        throw Exception('Failed to update employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating employee: $e');
    }
  }

  static Future<void> deleteEmployee(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/crews/employees/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting employee: $e');
    }
  }

  static Future<List<String>> getEmployeeBodies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/crews/employees/bodies'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<String>();
      } else {
        throw Exception('Failed to load bodies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading bodies: $e');
    }
  }

  static Future<List<int>> getEmployeeCrews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/crews/employees/crews'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<int>();
      } else {
        throw Exception('Failed to load crews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading crews: $e');
    }
  }

  // Robots API methods
  static Future<List<Robot>> getRobots({
    int skip = 0,
    int limit = 100,
    int? series,
    bool? hasBlockers,
  }) async {
    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      
      if (series != null) {
        queryParams['series'] = series.toString();
      }
      if (hasBlockers != null) {
        queryParams['has_blockers'] = hasBlockers.toString();
      }

      final uri = Uri.parse('$baseUrl/robots').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Robot.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load robots: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading robots: $e');
    }
  }

  static Future<Robot> getRobot(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/robots/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Robot.fromJson(json);
      } else {
        throw Exception('Failed to load robot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading robot: $e');
    }
  }

  static Future<Robot> createRobot(Map<String, dynamic> robotData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/robots'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(robotData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Robot.fromJson(json);
      } else {
        throw Exception('Failed to create robot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating robot: $e');
    }
  }

  static Future<Robot> updateRobot(int id, Map<String, dynamic> robotData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/robots/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(robotData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Robot.fromJson(json);
      } else {
        throw Exception('Failed to update robot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating robot: $e');
    }
  }

  static Future<void> deleteRobot(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/robots/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete robot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting robot: $e');
    }
  }

  // Transport API methods
  static Future<List<Transport>> getTransports({
    int skip = 0,
    int limit = 100,
    bool? carsharing,
    bool? corporate,
    bool? autoVc,
  }) async {
    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      
      if (carsharing != null) {
        queryParams['carsharing'] = carsharing.toString();
      }
      if (corporate != null) {
        queryParams['corporate'] = corporate.toString();
      }
      if (autoVc != null) {
        queryParams['auto_vc'] = autoVc.toString();
      }

      final uri = Uri.parse('$baseUrl/transport').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Transport.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading transports: $e');
    }
  }

  static Future<Transport> getTransport(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transport/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Transport.fromJson(json);
      } else {
        throw Exception('Failed to load transport: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading transport: $e');
    }
  }

  static Future<Transport> createTransport(Map<String, dynamic> transportData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transport'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transportData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Transport.fromJson(json);
      } else {
        throw Exception('Failed to create transport: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating transport: $e');
    }
  }

  static Future<Transport> updateTransport(int id, Map<String, dynamic> transportData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transport/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transportData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Transport.fromJson(json);
      } else {
        throw Exception('Failed to update transport: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating transport: $e');
    }
  }

  static Future<void> deleteTransport(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transport/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete transport: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting transport: $e');
    }
  }

}
