import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmora/screens/calculator_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:farmora/screens/product_list_screen.dart';
import 'package:farmora/services/profile_service.dart';
import 'package:farmora/models/profile_model.dart';
import 'package:farmora/screens/contacts_screen.dart';
import 'package:farmora/screens/profile_edit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  
  const DashboardScreen({
    required this.isDarkMode,
    required this.onThemeChanged,
    Key? key,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Modern color palette
  static const Color _primaryColor = Color(0xFF1E88E5); // Light blue
  static const Color _secondaryColor = Color(0xFF26A69A); // Teal
  static const Color _accentColor = Color(0xFF42A5F5); // Lighter blue
  static const Color _errorColor = Color(0xFFE53935); // Red
  static const Color _successColor = Color(0xFF43A047); // Green
  static const Color _neutralColor = Color(0xFF78909C); // Blue-grey

  int _selectedIndex = 0;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool _isBluetoothOn = false;
  bool _isScanning = false;
  List<ScanResult> _bluetoothDevices = [];
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  Profile? _userProfile;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _initConnectivity();
    _initBluetoothMonitoring();
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    widget.onThemeChanged(_isDarkMode);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _scanResultsSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  // Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await Connectivity().checkConnectivity();
    } catch (e) {
      debugPrint('Failed to get connectivity status: $e');
      return;
    }

    if (!mounted) return;

    setState(() {
      _connectionStatus = result;
    });

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (!mounted) return;
      setState(() {
        _connectionStatus = result;
      });
    });
  }

  // Initialize bluetooth monitoring
  void _initBluetoothMonitoring() async {
    try {
      _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
        if (!mounted) return;
        setState(() {
          _isBluetoothOn = state == BluetoothAdapterState.on;
        });
        // Start scanning if bluetooth is turned on
        if (state == BluetoothAdapterState.on && !_isScanning) {
          _startBluetoothScan();
        }
      });
    } catch (e) {
      debugPrint('Failed to monitor Bluetooth state: $e');
    }
  }

  void _startBluetoothScan() async {
    try {
      setState(() {
        _isScanning = true;
        _bluetoothDevices = [];
      });

      _scanResultsSubscription?.cancel();
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;
        setState(() {
          _bluetoothDevices = results;
        });
      }, onError: (e) {
        debugPrint('Scan error: $e');
      });

      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      
      setState(() {
        _isScanning = false;
      });
    } catch (e) {
      debugPrint('Failed to scan for Bluetooth devices: $e');
      setState(() {
        _isScanning = false;
      });
    }
  }

  Widget _buildProfileSection() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileEditScreen()),
        );
        _loadProfile(); // Refresh profile after editing
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final newPicturePath = await ProfileService.updateProfilePicture();
                if (newPicturePath != null) {
                  setState(() {
                    if (_userProfile != null) {
                      _userProfile!.profilePicturePath = newPicturePath;
                    }
                  });
                }
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage: _userProfile?.profilePicturePath != null
                        ? FileImage(File(_userProfile!.profilePicturePath!))
                        : null,
                    child: _userProfile?.profilePicturePath == null
                        ? Text(
                            _userProfile?.name.isNotEmpty == true
                                ? _userProfile!.name[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userProfile?.name ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _userProfile?.email ?? 'Loading...',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _userProfile?.phoneNumber ?? 'Loading...',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmora Dashboard'),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    title: 'Products',
                    icon: Icons.shopping_bag,
                    color: _primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductListScreen()),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Calculator',
                    icon: Icons.calculate,
                    color: _secondaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CalculatorScreen()),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Contacts',
                    icon: Icons.contacts,
                    color: _accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContactsScreen()),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Profile',
                    icon: Icons.person,
                    color: _neutralColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildStatusSection(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildStatusItem(
            icon: Icons.wifi,
            title: 'Network',
            value: _getConnectionStatus(),
            color: _getConnectionColor(),
          ),
          SizedBox(height: 8),
          _buildStatusItem(
            icon: Icons.bluetooth,
            title: 'Bluetooth',
            value: _isBluetoothOn ? 'Connected' : 'Disconnected',
            color: _isBluetoothOn ? _successColor : _errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getConnectionStatus() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'WiFi Connected';
      case ConnectivityResult.mobile:
        return 'Mobile Data Connected';
      case ConnectivityResult.ethernet:
        return 'Ethernet Connected';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth Connected';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  Color _getConnectionColor() {
    switch (_connectionStatus) {
      case ConnectivityResult.none:
        return _errorColor;
      default:
        return _successColor;
    }
  }
}
