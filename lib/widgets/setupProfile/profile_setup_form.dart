import 'package:flutter/material.dart';
import 'package:neural_nexus_protocol/widgets/authentication/input_field.dart';
import 'package:neural_nexus_protocol/widgets/common/inline_status_message.dart';
import 'package:neural_nexus_protocol/widgets/section_label.dart';
import 'package:neural_nexus_protocol/widgets/setupProfile/avatar_picker.dart';
import 'package:neural_nexus_protocol/widgets/setupProfile/country_dropdown.dart';

class ProfileSetupForm extends StatelessWidget {
  const ProfileSetupForm({
    super.key,
    required this.usernameController,
    required this.callsignController,
    required this.selectedCountry,
    required this.countries,
    required this.loadingCountries,
    required this.countriesError,
    required this.error,
    required this.onRetryCountries,
    required this.onAvatarSelected,
    required this.onCountrySelected,
  });

  final TextEditingController usernameController;
  final TextEditingController callsignController;
  final Map<String, String>? selectedCountry;
  final List<Map<String, String>> countries;
  final bool loadingCountries;
  final String? countriesError;
  final String? error;
  final VoidCallback onRetryCountries;
  final ValueChanged<String> onAvatarSelected;
  final ValueChanged<Map<String, String>> onCountrySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: 'select avatar'),
        const SizedBox(height: 12),
        AvatarPicker(onAvatarSelected: onAvatarSelected),
        const SizedBox(height: 28),
        InputField(
          label: 'agent username',
          keyBoardType: TextInputType.text,
          obscure: false,
          controller: usernameController,
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
        InputField(
          keyBoardType: TextInputType.text,
          label: 'callsign (optional)',
          obscure: false,
          controller: callsignController,
          hint: 'e.g. Shadow Wolf',
          validator: (v) {
            if ((v ?? '').length > 40) return 'Max 40 characters';
            return null;
          },
        ),
        const SizedBox(height: 20),
        SectionLabel(text: 'region'),
        const SizedBox(height: 8),
        if (loadingCountries)
          const InlineStatusMessage.loading(message: 'Loading countries...')
        else if (countriesError != null)
          InlineStatusMessage.error(
            error: countriesError!,
            onRetry: onRetryCountries,
          )
        else
          CountryDropdown(
            countries: countries,
            selectedCountry: selectedCountry,
            onCountrySelected: onCountrySelected,
          ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
