import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/providers/agent_provider.dart';
import 'package:neural_nexus_protocol/widgets/authentication/input_field.dart';
import 'package:neural_nexus_protocol/widgets/common/button.dart';
import 'package:neural_nexus_protocol/widgets/common/inline_status_message.dart';
import 'package:neural_nexus_protocol/widgets/section_label.dart';
import 'package:neural_nexus_protocol/widgets/setup_profile/avatar_picker.dart';
import 'package:neural_nexus_protocol/widgets/setup_profile/country_dropdown.dart';

import '../constants/colors.dart';
import '../models/agent.dart';
import '../services/api_service.dart';
import '../widgets/common/glow_text.dart';

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

  // ── country fetch ─────────────────────────────────────────────────
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
      if (mounted) setState(() => _loadingCountries = false);
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
                // ── title ─────────────────────────────────────────
                Center(
                  child: AnimatedBuilder(
                    animation: _flicker,
                    builder: (_, _) => Opacity(
                      opacity: _flicker.value,
                      child: GlowText(
                        text: 'set your agent profile'.toUpperCase(),
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Configure your neural identity',
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      color: NeuralColors.tealDim,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── avatar picker ─────────────────────────────────
                SectionLabel(text: 'select avatar'),
                const SizedBox(height: 12),
                AvatarPicker(
                  onAvatarSelected: (url) =>
                      setState(() => _selectedAvatar = url),
                ),

                const SizedBox(height: 28),

                // ── username ──────────────────────────────────────
                InputField(
                  label: 'agent username',
                  keyBoardType: TextInputType.text,
                  obscure: false,
                  controller: _usernameCtrl,
                  hint: 'Agent_X',
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Username is required';
                    if (s.length < 3 || s.length > 20) return '3–20 characters';
                    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(s)) {
                      return 'Letters, numbers, _ or - only';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── callsign ──────────────────────────────────────
                InputField(
                  keyBoardType: TextInputType.text,
                  label: 'callsign (optional)',
                  obscure: false,
                  controller: _callsignCtrl,
                  hint: 'e.g. Shadow Wolf',
                  validator: (v) {
                    if ((v ?? '').length > 40) return 'Max 40 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── country ───────────────────────────────────────
                SectionLabel(text: 'region'),
                const SizedBox(height: 8),

                if (_loadingCountries)
                  const InlineStatusMessage.loading(
                    message: 'Loading countries...',
                  )
                else if (_countriesError != null)
                  InlineStatusMessage.error(
                    error: _countriesError!,
                    onRetry: _fetchCountries,
                  )
                else
                  CountryDropdown(
                    countries: _countries,
                    selectedCountry: _selectedCountry,
                    onCountrySelected: (country) =>
                        setState(() => _selectedCountry = country),
                  ),

                // ── error ─────────────────────────────────────────
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 32),

                // ── submit ────────────────────────────────────────
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
