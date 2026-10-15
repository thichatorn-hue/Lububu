import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const LabubuSmartApp());
}

class LabubuSmartApp extends StatelessWidget {
  const LabubuSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Labubu Smart System',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blue,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ----------------- ข้อมูลจำลองในระบบ -----------------
class AppData {
  static String adminPassword = "8888";
  
  // ตั้งค่า User เริ่มต้นเป็น Lububu ตามที่กำหนด
  static Map<String, Map<String, dynamic>> users = {
    "Lububu": {
      "password": "2026",
      "leaseEndTime": DateTime.now().millisecondsSinceEpoch + (30 * 24 * 60 * 60 * 1000),
    }
  };
}

// ----------------- หน้า Login -----------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    String u = _usernameController.text.trim();
    String p = _passwordController.text;

    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ กรุณากรอกชื่อผู้ใช้และรหัสผ่านให้ครบถ้วน')),
      );
      return;
    }

    // เข้าระบบ Admin (Yuuma)
    if (u.toLowerCase() == "yuuma") {
      if (p == AppData.adminPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ รหัสผ่าน Admin ของ Yuuma ไม่ถูกต้อง!')),
        );
      }
      return;
    }

    // เข้าระบบ User ทั่วไป (เช่น Lububu)
    if (AppData.users.containsKey(u) && AppData.users[u]!["password"] == p) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserControlPage(username: u)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1e1e1e),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3a3a3a)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏰 Labubu Smart System', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 8),
                const Text('ระบบเข้าสู่ระบบเพื่อควบคุมห้องส่วนตัว', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้ (เช่น Yuuma หรือ Lububu)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'รหัสผ่าน', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size.fromHeight(50)),
                  onPressed: _login,
                  child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- หน้าควบคุมของ User (Lububu View) -----------------
class UserControlPage extends StatefulWidget {
  final String username;
  const UserControlPage({super.key, required this.username});

  @override
  State<UserControlPage> createState() => _UserControlPageState();
}

class _UserControlPageState extends State<UserControlPage> {
  int currentTemp = 24;
  bool isDoorUnlocked = false;
  final _doorPassController = TextEditingController();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  bool isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    var userObj = AppData.users[widget.username];
    if (userObj == null) return;
    int endTime = userObj["leaseEndTime"];
    int now = DateTime.now().millisecondsSinceEpoch;
    int diff = endTime - now;

    setState(() {
      if (diff <= 0) {
        isExpired = true;
        _timeLeft = Duration.zero;
      } else {
        isExpired = false;
        _timeLeft = Duration(milliseconds: diff);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _unlockDoor() {
    String pass = _doorPassController.text;
    if (AppData.users[widget.username]?["password"] == pass) {
      setState(() {
        isDoorUnlocked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 ปลดล็อกประตูห้องเรียบร้อยแล้ว!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ รหัสผ่านไม่ถูกต้อง!')));
    }
    _doorPassController.clear();
  }

  void _changePassword() {
    String oldP = _oldPassController.text;
    String newP = _newPassController.text.trim();

    if (AppData.users[widget.username]?["password"] == oldP) {
      if (newP.length >= 4) {
        AppData.users[widget.username]?["password"] = newP;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ เปลี่ยนรหัสผ่านสำเร็จเรียบร้อย!')));
        _oldPassController.clear();
        _newPassController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ กรุณาตั้งรหัสผ่านใหม่อย่างน้อย 4 ตัวอักษร')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ รหัสผ่านเดิมไม่ถูกต้อง!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeStr = "${_timeLeft.inDays} วัน "
        "${(_timeLeft.inHours % 24).toString().padLeft(2, '0')}:"
        "${(_timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Text('🐰 ห้องพักของ: ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
              child: Text('เวลาเช่าคงเหลือ:\n$timeStr', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            if (isExpired)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                child: const Text('⚠️ สัญญาเช่าของคุณหมดอายุแล้ว! กรุณาติดต่อ Yuuma (Admin)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 12),
            // Smart Door Card
            Card(
              color: const Color(0xFF2a2a2a),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔑 Smart Door Lock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(isDoorUnlocked ? 'สถานะ: 🔓 ปลดล็อกแล้ว' : 'สถานะ: 🔒 ล็อกอยู่', style: TextStyle(color: isDoorUnlocked ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(controller: _doorPassController, decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่านเพื่อปลดล็อก', border: OutlineInputBorder()), obscureText: true),
                    const SizedBox(height: 8),
                    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size.fromHeight(40)), onPressed: _unlockDoor, child: const Text('ปลดล็อกประตู', style: TextStyle(color: Colors.white))),
                    const Divider(height: 24),
                    const Text('เปลี่ยนรหัสผ่านบัญชีของคุณ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(controller: _oldPassController, decoration: const InputDecoration(labelText: 'รหัสผ่านปัจจุบัน'), obscureText: true),
                    TextField(controller: _newPassController, decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่ (อย่างน้อย 4 ตัว)'), obscureText: true),
                    const SizedBox(height: 8),
                    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, minimumSize: const Size.fromHeight(40)), onPressed: _changePassword, child: const Text('บันทึกรหัสใหม่', style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // AC Card
            Card(
              color: const Color(0xFF2a2a2a),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('❄️ ควบคุมเครื่องปรับอากาศ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$currentTemp°C', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.cyan)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(onPressed: () => setState(() => currentTemp = currentTemp > 16 ? currentTemp - 1 : 16), child: const Text('-', style: TextStyle(fontSize: 20))),
                        const SizedBox(width: 20),
                        ElevatedButton(onPressed: () => setState(() => currentTemp = currentTemp < 30 ? currentTemp + 1 : 30), child: const Text('+', style: TextStyle(fontSize: 20))),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- หน้าแดชบอร์ด Admin (Yuuma) -----------------
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _newUserNameController = TextEditingController();
  final _newUserPassController = TextEditingController();
  final _newUserDaysController = TextEditingController(text: '30');
  
  final _oldAdminPassController = TextEditingController();
  final _newAdminPassController = TextEditingController();

  void _createNewUser() {
    String u = _newUserNameController.text.trim();
    String p = _newUserPassController.text.trim();
    int? days = int.tryParse(_newUserDaysController.text);

    if (u.isEmpty || p.isEmpty || days == null || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ กรุณากรอกข้อมูลให้ครบถ้วน')));
      return;
    }
    if (u.toLowerCase() == "yuuma") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ ไม่สามารถใช้ชื่อ Admin เป็น User ได้')));
      return;
    }
    if (AppData.users.containsKey(u)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ มีชื่อผู้ใช้นี้อยู่ในระบบแล้ว')));
      return;
    }

    AppData.users[u] = {
      "password": p,
      "leaseEndTime": DateTime.now().millisecondsSinceEpoch + (days * 24 * 60 * 60 * 1000)
    };

    _newUserNameController.clear();
    _newUserPassController.clear();
    _newUserDaysController.text = '30';
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ สร้างผู้ใช้ "$u" เรียบร้อยแล้ว!')));
  }

  void _changeAdminPassword() {
    String oldP = _oldAdminPassController.text;
    String newP = _newAdminPassController.text.trim();

    if (oldP == AppData.adminPassword) {
      if (newP.length >= 4) {
        AppData.adminPassword = newP;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ เปลี่ยนรหัสผ่าน Admin เรียบร้อยแล้ว!')));
        _oldAdminPassController.clear();
        _newAdminPassController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ รหัสผ่านใหม่ต้องมีอย่างน้อย 4 ตัวอักษร')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ รหัสผ่าน Admin เดิมไม่ถูกต้อง')));
    }
  }

  void _addDaysToUser(String u) {
    TextEditingController daysInput = TextEditingController(text: '7');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ขยายเวลาเช่าให้ $u'),
        content: TextField(
          controller: daysInput,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'จำนวนวันที่ต้องการเพิ่ม'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              int? d = int.tryParse(daysInput.text);
              if (d != null && d > 0) {
                int now = DateTime.now().millisecondsSinceEpoch;
                int currentEnd = AppData.users[u]!["leaseEndTime"];
                if (currentEnd < now) {
                  AppData.users[u]!["leaseEndTime"] = now + (d * 24 * 60 * 60 * 1000);
                } else {
                  AppData.users[u]!["leaseEndTime"] += (d * 24 * 60 * 60 * 1000);
                }
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ เพิ่มเวลาให้ $u อีก $d วันเรียบร้อยแล้ว!')));
              }
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👑 Yuuma Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // สร้าง User ใหม่
          Card(
            color: const Color(0xFF2a2a2a),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('➕ สร้าง User ใหม่ให้ Labubu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextField(controller: _newUserNameController, decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้ (Username)')),
                  TextField(controller: _newUserPassController, decoration: const InputDecoration(labelText: 'รหัสผ่านเริ่มต้น')),
                  TextField(controller: _newUserDaysController, decoration: const InputDecoration(labelText: 'จำนวนวันสิทธิ์การใช้งาน'), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size.fromHeight(40)), onPressed: _createNewUser, child: const Text('สร้างบัญชีผู้ใช้', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // เปลี่ยนรหัสผ่าน Admin
          Card(
            color: const Color(0xFF2a2a2a),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔒 เปลี่ยนรหัสผ่าน Admin ของ Yuuma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextField(controller: _oldAdminPassController, decoration: const InputDecoration(labelText: 'รหัสผ่าน Admin ปัจจุบัน'), obscureText: true),
                  TextField(controller: _newAdminPassController, decoration: const InputDecoration(labelText: 'รหัสผ่าน Admin ใหม่'), obscureText: true),
                  const SizedBox(height: 12),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, minimumSize: const Size.fromHeight(40)), onPressed: _changeAdminPassword, child: const Text('อัปเดตรหัสผ่าน Admin', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // รายชื่อ User ทั้งหมด
          Card(
            color: const Color(0xFF2a2a2a),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📋 รายชื่อ User และจัดการสิทธิ์', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...AppData.users.keys.map((u) {
                    var data = AppData.users[u]!;
                    int diff = data["leaseEndTime"] - DateTime.now().millisecondsSinceEpoch;
                    int daysLeft = diff > 0 ? (diff / (1000 * 60 * 60 * 24)).floor() : 0;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('👤 $u (Password: ${data["password"]})', style: const TextStyle(fontWeight: FontWeight.bold
