import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neural_nexus_protocol/constants/colors.dart';
import 'package:neural_nexus_protocol/services/audio_service.dart';

class CountryDropdown extends StatefulWidget {
  const CountryDropdown({
    super.key,
    required this.countries,
    this.selectedCountry,
    required this.onCountrySelected,
  });

  final List<Map<String, String>> countries;
  final Map<String, String>? selectedCountry;
  final void Function(Map<String, String>) onCountrySelected;

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  bool _showSearch = false;
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.countries;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = widget.countries
          .where((c) => c['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggle() async {
    await AppAudioService.instance.playSoftTap();
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        _searchCtrl.clear();
        _filtered = widget.countries;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Trigger
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: _showSearch
                    ? NeuralColors.tealDim
                    : NeuralColors.tealDark,
                width: _showSearch ? 1.5 : 1,
              ),
              color: NeuralColors.teal.withValues(alpha: 0.02),
            ),
            child: Row(
              children: [
                Text(
                  widget.selectedCountry != null
                      ? '${widget.selectedCountry!['flag']}  ${widget.selectedCountry!['name']}'
                      : 'Select country...',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: widget.selectedCountry != null
                        ? NeuralColors.textMain
                        : NeuralColors.tealBorder,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showSearch
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: NeuralColors.tealDim,
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        // Dropdown
        if (_showSearch)
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: NeuralColors.tealDark),
                right: BorderSide(color: NeuralColors.tealDark),
                bottom: BorderSide(color: NeuralColors.tealDark),
              ),
              color: NeuralColors.bg2,
            ),
            child: Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      color: NeuralColors.textMain,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.spaceMono(
                        fontSize: 11,
                        color: NeuralColors.tealBorder,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: NeuralColors.tealDim,
                        size: 16,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: NeuralColors.tealDark),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: NeuralColors.tealDim,
                          width: 1.5,
                        ),
                      ),
                    ),
                    cursorColor: NeuralColors.teal,
                  ),
                ),

                // Country list
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      final isSelected =
                          widget.selectedCountry?['name'] == c['name'];
                      return GestureDetector(
                        onTap: () async {
                          await AppAudioService.instance.playSoftTap();
                          widget.onCountrySelected(c);
                          setState(() => _showSearch = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          color: isSelected
                              ? NeuralColors.teal.withValues(alpha: 0.1)
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Text(
                                c['flag']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                c['name']!,
                                style: GoogleFonts.spaceMono(
                                  fontSize: 11,
                                  color: isSelected
                                      ? NeuralColors.teal
                                      : NeuralColors.textMain,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
