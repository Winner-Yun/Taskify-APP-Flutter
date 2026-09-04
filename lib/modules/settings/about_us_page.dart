import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_do_list_app/core/constants/appcolor.dart';

class AboutUsPage extends StatelessWidget {
  final bool dark;
  const AboutUsPage({super.key, required this.dark});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: AppColors.background(dark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(dark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Us',
          style: TextStyle(
            color: AppColors.text(dark),
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset('assets/icons/logoTaskify.png', fit: BoxFit.fill),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Taskify',
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.text(dark),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 0.1.0',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.text(dark).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              context: context,
              title: 'អំពីកម្មវិធី',
              content:
                  'Taskify គឺជាកម្មវិធីគ្រប់គ្រងការងារងាយស្រួលប្រើ និងមានអត្ថប្រយោជន៍ដែលត្រូវបានបង្កើតឡើងសម្រាប់ការប្រើប្រាស់ប្រចាំថ្ងៃ។ វាជួយអ្នកតាមដានការងារ កំណត់ចំណាំ និងរៀបចំពេលវេលារបស់អ្នកបានកាន់តែងាយស្រួល។\n\n'
                  'Taskify គឺអាចប្រើប្រាស់បានដោយឥតគិតថ្លៃទាំងស្រុង ដោយគ្មានការផ្សាយពាណិជ្ជកម្មរំខាន។ យើងបង្កើតវាឡើងដើម្បីផ្តល់នូវបទពិសោធន៍សាមញ្ញ ដោយគ្មានមុខងារស្មុគស្មាញច្រើន។\n\n'
                  'Taskify ត្រូវបានបង្កើតឡើងដោយ Winner Yun នៅឆ្នាំ 2026 ជាផ្នែកមួយនៃ Khansha Team។',
            ),
            const SizedBox(height: 24),
            _buildContactSection(
              context: context,
              title: 'ទំនាក់ទំនងមកកាន់យើង',
              phone: '+855 81 513 746',
              email: 'winnerlegendpvh1426@gmail.com',
              facebook: 'Winner Yun',
              slogan: 'Taskify: ងាយស្រួលកត់ត្រាការងារ រៀបចំជីវិតរបស់អ្នក។',
            ),

            const SizedBox(height: 32),
            Divider(color: AppColors.text(dark).withOpacity(0.1)),
            const SizedBox(height: 32),

            _buildSection(
              context: context,
              title: 'English',
              content:
                  'Taskify is a simple and useful to-do list app created for everyday use. It helps you track your tasks, set reminders, and organize your time easily and conveniently.\n\n'
                  'Taskify is completely free to use with no advertisements. We created it to provide a simple experience without unnecessary distractions.\n\n'
                  'Taskify was created by Winner Yun in 2026 as part of the Khansha Team.',
            ),
            const SizedBox(height: 24),
            _buildContactSection(
              context: context,
              title: 'Contact Us',
              phone: '+855 81 513 746',
              email: 'winnerlegendpvh1426@gmail.com',
              facebook: 'Winner Yun',
              slogan: 'Taskify: Simple tasks, organized life.',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.primary(dark),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.text(dark),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection({
    required BuildContext context,
    required String title,
    required String phone,
    required String email,
    required String facebook,
    required String slogan,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(dark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(dark).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.text(dark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactRow(context, Icons.phone_rounded, phone),
          const SizedBox(height: 12),
          _buildContactRow(context, Icons.email_rounded, email),
          const SizedBox(height: 12),
          _buildContactRow(context, Icons.facebook_rounded, facebook),
          const SizedBox(height: 16),
          Divider(color: AppColors.text(dark).withOpacity(0.1)),
          const SizedBox(height: 12),
          Text(
            slogan,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.primary(dark),
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.text(dark).withOpacity(0.5)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text(dark),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
