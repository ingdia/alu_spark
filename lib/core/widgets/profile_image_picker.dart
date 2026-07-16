import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/utils/url_utils.dart';

/// Circular avatar with an edit overlay.
/// Calls [onUrlSaved] with the new URL, or [onRemoved] when the user removes.
class ProfileImagePicker extends StatelessWidget {
  final String? currentImageUrl;
  final String initials;
  final double radius;
  final void Function(String url) onUrlSaved;
  final VoidCallback onRemoved;

  const ProfileImagePicker({
    super.key,
    required this.currentImageUrl,
    required this.initials,
    required this.onUrlSaved,
    required this.onRemoved,
    this.radius = 48,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkBlueLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UrlInputSheet(
        currentUrl: currentImageUrl,
        onSaved: (url) {
          Navigator.pop(context);
          onUrlSaved(url);
        },
        onRemoved: currentImageUrl != null
            ? () {
                Navigator.pop(context);
                onRemoved();
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.darkBlueLight,
            backgroundImage: currentImageUrl != null
                ? NetworkImage(currentImageUrl!)
                : null,
            child: currentImageUrl == null
                ? Text(
                    initials,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: radius * 0.55,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.darkRed,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkBlue, width: 2),
              ),
              child: const Icon(Icons.edit, color: AppColors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrlInputSheet extends StatefulWidget {
  final String? currentUrl;
  final void Function(String url) onSaved;
  final VoidCallback? onRemoved;

  const _UrlInputSheet({
    required this.currentUrl,
    required this.onSaved,
    this.onRemoved,
  });

  @override
  State<_UrlInputSheet> createState() => _UrlInputSheetState();
}

class _UrlInputSheetState extends State<_UrlInputSheet> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUrl ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = 'Please enter a URL.');
      return;
    }
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      setState(() => _error = 'URL must start with http:// or https://');
      return;
    }
    widget.onSaved(UrlUtils.normalizeImageUrl(raw));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGlass,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.currentUrl != null ? 'Change Photo URL' : 'Set Photo URL',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Paste a direct image URL from Google Drive, Dropbox, OneDrive, GitHub, or any public image link.',
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _error != null ? AppColors.darkRed : AppColors.borderGlass,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _controller,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              keyboardType: TextInputType.url,
              autocorrect: false,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                hintText: 'https://...',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(_error!,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.darkRed, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('Save',
                  style:
                      AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
            ),
          ),
          if (widget.onRemoved != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: widget.onRemoved,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppColors.darkRed.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Remove Photo',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.darkRed)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
