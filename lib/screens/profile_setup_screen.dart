import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/models/agent.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/services/api_service.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/setupProfile/profile_setup_form.dart';
import 'package:neural_nexus_protocol/widgets/setupProfile/profile_setup_header.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _callsignCtrl = TextEditingController();

  String? _selectedAvatar;
  Map<String, String>? _selectedCountry;

  List<Map<String, String>> _countries = [];
  bool _loadingCountries = true;
  String? _countriesError;
  String? _error;

  late AnimationController _flickerCtrl;
  late Animation<double> _flicker;

  @override
  void initState() {
    super.initState();

    _flickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _flicker = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 92),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 0.5),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 0.5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 0.5),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 6.5),
    ]).animate(_flickerCtrl);

    _fetchCountries();
  }

  @override
  void dispose() {
    _flickerCtrl.dispose();
    _usernameCtrl.dispose();
    _callsignCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    setState(() {
      _loadingCountries = true;
      _countriesError = null;
    });
    try {
      final data = await ApiService.fetchCountries();
      setState(() => _countries = data);
    } catch (_) {
      setState(() => _countriesError = 'Could not load countries');
    } finally {
      if (mounted) {
        setState(() => _loadingCountries = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedAvatar == null) {
      setState(() => _error = 'Please select an avatar');
      return;
    }

    setState(() => _error = null);

    try {
      final Agent agent = await ApiService.setupProfile(
        username: _usernameCtrl.text.trim(),
        avatarUrl: _selectedAvatar!,
        callsign: _callsignCtrl.text.trim(),
        country: _selectedCountry != null
            ? '${_selectedCountry!['flag']} ${_selectedCountry!['name']}'
            : null,
      );

      ref.read(agentProvider.notifier).state = agent;

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home', (route) => false, arguments: agent);
    } on Exception catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuralColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSetupHeader(flicker: _flicker),
                const SizedBox(height: 32),
                ProfileSetupForm(
                  usernameController: _usernameCtrl,
                  callsignController: _callsignCtrl,
                  selectedCountry: _selectedCountry,
                  countries: _countries,
                  loadingCountries: _loadingCountries,
                  countriesError: _countriesError,
                  error: _error,
                  onRetryCountries: _fetchCountries,
                  onAvatarSelected: (url) {
                    setState(() => _selectedAvatar = url);
                  },
                  onCountrySelected: (country) {
                    setState(() => _selectedCountry = country);
                  },
                ),
                const SizedBox(height: 32),
                Button(text: 'save agent', onTap: _handleSubmit),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
