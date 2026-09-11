import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../models/photo_model.dart';
import '../services/filter_service.dart';
import '../state/session_state.dart';
import 'rendering_screen.dart';

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  PhotoColorFilter _selected = PhotoColorFilter.original;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final photos = session.photos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Filter Warna'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _selected.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview grid foto dengan filter realtime via ColorFiltered
          Expanded(
            child: photos.isEmpty
                ? const Center(child: Text('Tidak ada foto untuk preview'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, i) {
                      final photo = photos[i];
                      final url =
                          '${AppConfig.baseUrl.replaceFirst('/api', '')}/storage/${photo.filePath}';
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColorFiltered(
                              colorFilter: FilterService.colorFilter(_selected),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, progress) =>
                                    progress == null ? child : const Center(child: CircularProgressIndicator()),
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade900,
                                  child: const Icon(Icons.broken_image, color: Colors.white54),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Slot ${photo.slotIndex + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Info filter terpilih
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.filter_alt, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Filter: ${_selected.label}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                if (_selected != PhotoColorFilter.original)
                  TextButton(
                    onPressed: () => setState(() => _selected = PhotoColorFilter.original),
                    child: const Text('Reset'),
                  ),
              ],
            ),
          ),

          // Horizontal selector dengan thumbnail preview
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: PhotoColorFilter.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final filter = PhotoColorFilter.values[i];
                final isSelected = filter == _selected;
                final thumbUrl = photos.isNotEmpty
                    ? '${AppConfig.baseUrl.replaceFirst('/api', '')}/storage/${photos.first.filePath}'
                    : null;

                return GestureDetector(
                  onTap: () => setState(() => _selected = filter),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade600,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: thumbUrl != null
                            ? ColorFiltered(
                                colorFilter: FilterService.colorFilter(filter),
                                child: Image.network(
                                  thumbUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 28),
                                ),
                              )
                            : ColorFiltered(
                                colorFilter: FilterService.colorFilter(filter),
                                child: Container(
                                  color: Colors.primaries[i % Colors.primaries.length],
                                  child: const Icon(Icons.filter, color: Colors.white),
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filter.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Tombol konfirmasi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        try {
                          await ref.read(sessionProvider.notifier).setFilter(_selected);
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RenderingScreen()),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal set filter: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _saving = false);
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Konfirmasi & Lanjutkan', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
