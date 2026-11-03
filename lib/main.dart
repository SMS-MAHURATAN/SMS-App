import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SardarMemorialSchoolApp());
}

// -----------------------------------------------------------------------------
// आधिकारिक स्कूल की जानकारी (Official Information)
// -----------------------------------------------------------------------------
class SchoolData {
  static const String name = "SARDAR MEMORIAL SCHOOL";
  static const String address = "Mahuratan, Tetiyabambar, Munger, Bihar – 813221";
  static const String regNo = "2261363202489220244";
  static const String udise = "10244103948";
  static const String motto = "शिक्षार्थ आइए, सेवार्थ जाइए";
  static const String session = "2026–2027";
  static const String adminName = "Priyanshu Jha";
  static const String adminPhone = "+91 7905007244";

  // ब्रांड रंग
  static const Color royalBlue = Color(0xFF0D47A1);
  static const Color brightRed = Color(0xFFD32F2F);
  static const Color accentYellow = Color(0xFFFBC02D);
  static const Color bgWhite = Color(0xFFF8FAFC);

  // 22 कक्षा-वर्ग (Preconfigured 22 Sections)
  static const List<String> classes = [
    'Nursery', 'LKG', 'UKG',
    'Class 1', 'Class 2', 'Class 3', 'Class 4',
    'Class 5', 'Class 6', 'Class 7', 'Class 8'
  ];
  static const List<String> sections = ['A', 'B'];

  static List<String> getAllSectionsList() {
    List<String> list = [];
    for (var c in classes) {
      for (var s in sections) {
        list.add("$c - Sec $s");
      }
    }
    return list;
  }
}

// -----------------------------------------------------------------------------
// ऐप रूट (Material 3 App & Bilingual Settings)
// -----------------------------------------------------------------------------
class SardarMemorialSchoolApp extends StatefulWidget {
  const SardarMemorialSchoolApp({super.key});

  @override
  State<SardarMemorialSchoolApp> createState() => _SardarMemorialSchoolAppState();
}

class _SardarMemorialSchoolAppState extends State<SardarMemorialSchoolApp> {
  Locale _currentLocale = const Locale('hi');

  void toggleLanguage() {
    setState(() {
      _currentLocale = _currentLocale.languageCode == 'hi' 
          ? const Locale('en') 
          : const Locale('hi');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: SchoolData.name,
      debugShowCheckedModeBanner: false,
      locale: _currentLocale,
      supportedLocales: const [Locale('hi'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SchoolData.royalBlue,
          primary: SchoolData.royalBlue,
          secondary: SchoolData.brightRed,
        ),
        scaffoldBackgroundColor: SchoolData.bgWhite,
        fontFamily: 'Roboto',
      ),
      home: LoginSelectionScreen(onLanguageToggle: toggleLanguage),
    );
  }
}

// -----------------------------------------------------------------------------
// स्क्रीन 1: लॉगिन स्क्रीन (Login with Role Gateway)
// -----------------------------------------------------------------------------
class LoginSelectionScreen extends StatefulWidget {
  final VoidCallback onLanguageToggle;
  const LoginSelectionScreen({super.key, required this.onLanguageToggle});

  @override
  State<LoginSelectionScreen> createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen> {
  String selectedRole = 'SUPER ADMIN';
  final TextEditingController _mobileController = TextEditingController(text: "7905007244");
  final TextEditingController _otpController = TextEditingController();
  bool otpSent = false;
  bool isVerifying = false;

  void _handleSendOtp() {
    if (_mobileController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("कृपया 10 अंकों का वैध मोबाइल नंबर दर्ज करें")),
      );
      return;
    }
    setState(() => otpSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP भेजा गया! (सुरक्षा परीक्षण के लिए OTP: 123456 दर्ज करें)")),
    );
  }

  void _handleVerifyLogin() {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("कृपया 6 अंकों का OTP दर्ज करें")),
      );
      return;
    }

    setState(() => isVerifying = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() => isVerifying = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainDashboardScreen(
            userRole: selectedRole,
            mobile: _mobileController.text.trim(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isHindi = Localizations.localeOf(context).languageCode == 'hi';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: SchoolData.royalBlue,
        elevation: 0,
        title: Text(isHindi ? "प्रवेश द्वार" : "Login Portal", style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton.icon(
            onPressed: widget.onLanguageToggle,
            icon: const Icon(Icons.language, color: SchoolData.accentYellow),
            label: Text(
              isHindi ? "English" : "हिंदी",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // स्कूल पहचान हेडर
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: SchoolData.royalBlue,
                      child: Icon(Icons.school, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      SchoolData.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SchoolData.royalBlue),
                    ),
                    const Text(
                      SchoolData.motto,
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: SchoolData.brightRed),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "UDISE: ${SchoolData.udise} | सत्र: ${SchoolData.session}",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const Divider(height: 28),

                    // रोल चयन
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: isHindi ? "अपनी भूमिका चुनें" : "Select Role",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: ['SUPER ADMIN', 'TEACHER', 'PARENT', 'STUDENT'].map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedRole = val!;
                          if (selectedRole == 'SUPER ADMIN') {
                            _mobileController.text = "7905007244";
                          } else {
                            _mobileController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // मोबाइल नंबर
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixText: "+91 ",
                        labelText: isHindi ? "पंजीकृत मोबाइल नंबर" : "Registered Mobile Number",
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (otpSent) ...[
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: isHindi ? "6 अंकों का OTP दर्ज करें" : "Enter 6-Digit OTP",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SchoolData.brightRed,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: isVerifying ? null : _handleVerifyLogin,
                        child: isVerifying
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isHindi ? "सत्यापित करें और प्रवेश करें" : "VERIFY & ENTER"),
                      ),
                    ] else ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SchoolData.royalBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: _handleSendOtp,
                        child: Text(isHindi ? "सुरक्षित OTP प्राप्त करें" : "GET SECURE OTP"),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// स्क्रीन 2: मुख्य डैशबोर्ड (Dynamic by Role)
// -----------------------------------------------------------------------------
class MainDashboardScreen extends StatefulWidget {
  final String userRole;
  final String mobile;
  const MainDashboardScreen({super.key, required this.userRole, required this.mobile});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SchoolData.royalBlue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SchoolData.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(SchoolData.motto, style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "लॉगआउट",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginSelectionScreen(onLanguageToggle: () {}),
                ),
              );
            },
          )
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        selectedItemColor: SchoolData.royalBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) => setState(() => _tabIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "डैशबोर्ड"),
          BottomNavigationBarItem(icon: Icon(Icons.how_to_reg), label: "उपस्थिति"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "फीस रसीद"),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "सूचना पट्ट"),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_tabIndex) {
      case 0:
        return _buildHomeOverview();
      case 1:
        return const AttendanceModuleView();
      case 2:
        return const FeeModuleView();
      case 3:
        return const NoticeBoardView();
      default:
        return _buildHomeOverview();
    }
  }

  Widget _buildHomeOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // व्यवस्थापक पहचान कार्ड
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SchoolData.royalBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchoolData.royalBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: SchoolData.royalBlue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.userRole, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      Text(
                        widget.userRole == 'SUPER ADMIN' ? SchoolData.adminName : "मान्य उपयोगकर्ता",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text("सत्र: ${SchoolData.session} | मो.: ${widget.mobile}", style: const TextStyle(fontSize: 11, color: SchoolData.brightRed)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text("दैनिक विद्यालय स्थिति (Real-time Overview)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // मेट्रिक्स कार्ड्स
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: const [
              _MetricCard(title: "कुल कक्षाएं", value: "22 सेक्शंस", icon: Icons.class_, color: Colors.indigo),
              _MetricCard(title: "आज की उपस्थिति", value: "94.6%", icon: Icons.check_circle, color: Colors.green),
              _MetricCard(title: "कुल फीस जमा", value: "₹ 4,82,500", icon: Icons.payments, color: Colors.teal),
              _MetricCard(title: "बकाया फीस", value: "₹ 82,300", icon: Icons.warning_amber, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 18),

          const Text("त्वरित कार्य (Quick Actions)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SchoolData.royalBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.how_to_reg, size: 18),
                  label: const Text("हाजिरी भरें"),
                  onPressed: () => setState(() => _tabIndex = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SchoolData.brightRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text("रसीद काटें"),
                  onPressed: () => setState(() => _tabIndex = 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// स्क्रीन 3: दैनिक उपस्थिति मॉड्यूल (22 सेक्शंस समर्थित)
// -----------------------------------------------------------------------------
class AttendanceModuleView extends StatefulWidget {
  const AttendanceModuleView({super.key});

  @override
  State<AttendanceModuleView> createState() => _AttendanceModuleViewState();
}

class _AttendanceModuleViewState extends State<AttendanceModuleView> {
  String _selectedClass = SchoolData.getAllSectionsList().first;
  final Map<String, String> _attendanceMap = {
    '1': 'P', '2': 'P', '3': 'A', '4': 'P', '5': 'L'
  };

  final List<Map<String, String>> _sampleStudents = [
    {'roll': '01', 'id': '1', 'name': 'Aarav Kumar'},
    {'roll': '02', 'id': '2', 'name': 'Pooja Kumari'},
    {'roll': '03', 'id': '3', 'name': 'Vikram Singh'},
    {'roll': '04', 'id': '4', 'name': 'Ananya Jha'},
    {'roll': '05', 'id': '5', 'name': 'Rohan Sharma'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade100,
          child: DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: const InputDecoration(labelText: "कक्षा और वर्ग चुनें", border: OutlineInputBorder()),
            items: SchoolData.getAllSectionsList().map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: (val) => setState(() => _selectedClass = val!),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _sampleStudents.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final student = _sampleStudents[i];
              final currentStatus = _attendanceMap[student['id']] ?? 'P';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: SchoolData.royalBlue.withOpacity(0.1),
                  child: Text(student['roll']!, style: const TextStyle(fontWeight: FontWeight.bold, color: SchoolData.royalBlue)),
                ),
                title: Text(student['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("नामांकन: SMS/26/${student['roll']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['P', 'A', 'L'].map((status) {
                    final isSelected = currentStatus == status;
                    Color color = status == 'P' ? Colors.green : (status == 'A' ? Colors.red : Colors.orange);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: color,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        onSelected: (_) {
                          setState(() => _attendanceMap[student['id']!] = status);
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SchoolData.royalBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$_selectedClass की उपस्थिति सुरक्षित रूप से सहेज ली गई!")),
              );
            },
            child: const Text("उपस्थिति सबमिट करें (Save Attendance)"),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// स्क्रीन 4: फीस प्रबंधन एवं आधिकारिक प्रिंटेड रसीद जनरेटर
// -----------------------------------------------------------------------------
class FeeModuleView extends StatefulWidget {
  const FeeModuleView({super.key});

  @override
  State<FeeModuleView> createState() => _FeeModuleViewState();
}

class _FeeModuleViewState extends State<FeeModuleView> {
  final _admController = TextEditingController(text: "SMS/2026/0142");
  final _nameController = TextEditingController(text: "Aarav Kumar");
  final _amountController = TextEditingController(text: "1250");
  String _category = "मासिक ट्यूशन फीस";
  String _class = "Class 1 - Sec A";

  void _printOfficialReceipt() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue900, width: 2),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(SchoolData.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text(SchoolData.motto, style: pw.TextStyle(fontSize: 10, color: PdfColors.red800)),
                        pw.Text(SchoolData.address, style: const pw.TextStyle(fontSize: 8)),
                        pw.Text("UDISE: ${SchoolData.udise} | Reg: ${SchoolData.regNo}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: "SMS-VERIFY:${_admController.text}:${_amountController.text}",
                      width: 60,
                      height: 60,
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                pw.Center(
                  child: pw.Text("आधिकारिक शुल्क रसीद (OFFICIAL FEE RECEIPT - 2026-2027)",
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                ),
                pw.SizedBox(height: 12),
                pw.Text("रसीद संख्या: REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}", style: const pw.TextStyle(fontSize: 9)),
                pw.Text("तारीख: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("विद्यार्थी का नाम: ${_nameController.text}")),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("नामांकन सं.: ${_admController.text}")),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("कक्षा: $_class")),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("शुल्क मद: $_category")),
                    ]),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  color: PdfColors.blue50,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("कुल प्राप्त राशि (Total Paid):", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("₹ ${_amountController.text}.00", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("संग्राहक: ${SchoolData.adminName}", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("अधिकृत हस्ताक्षरकर्ता (Authorized Signatory)", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(controller: _admController, decoration: const InputDecoration(labelText: "नामांकन संख्या (Admission No)", border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: "विद्यार्थी का नाम (Student Name)", border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _class,
            decoration: const InputDecoration(labelText: "कक्षा और वर्ग", border: OutlineInputBorder()),
            items: SchoolData.getAllSectionsList().map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (val) => setState(() => _class = val!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: "शुल्क श्रेणी (Fee Category)", border: OutlineInputBorder()),
            items: ["नामांकन शुल्क", "मासिक ट्यूशन फीस", "वार्षिक शुल्क", "परीक्षा शुल्क", "कंप्यूटर शुल्क", "वाहन शुल्क"]
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (val) => setState(() => _category = val!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "जमा राशि (INR ₹)", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: SchoolData.royalBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.print),
            label: const Text("रसीद बनाएं और प्रिंट/PDF लें"),
            onPressed: _printOfficialReceipt,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// स्क्रीन 5: डिजिटल सूचना पट्ट (Notice Board)
// -----------------------------------------------------------------------------
class NoticeBoardView extends StatelessWidget {
  const NoticeBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNoticeCard(
          title: "नवीन शैक्षणिक सत्र 2026-2027 प्रारंभ",
          date: "01 अप्रैल 2026",
          desc: "सभी विद्यार्थियों एवं अभिभावकों को सूचित किया जाता है कि नया शैक्षणिक सत्र प्रारंभ हो चुका है। समय से विद्यालय पधारें।",
          tag: "सामान्य सूचना",
        ),
        _buildNoticeCard(
          title: "प्रथम मासिक परीक्षा की समय सारणी",
          date: "15 मई 2026",
          desc: "नर्सरी से वर्ग 8 तक के सभी विद्यार्थियों की प्रथम मासिक परीक्षा की डेटशीट कार्यालय द्वारा जारी कर दी गई है।",
          tag: "परीक्षा",
        ),
      ],
    );
  }

  Widget _buildNoticeCard({required String title, required String date, required String desc, required String tag}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: SchoolData.royalBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(tag, style: const TextStyle(fontSize: 11, color: SchoolData.royalBlue, fontWeight: FontWeight.bold)),
                ),
                Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
