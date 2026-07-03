import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/advertisement.dart';
import '../widgets/tabib_image.dart';

/// Auto-sliding city advertisement carousel for the patient home screen.
class AdvertisementCarousel extends StatefulWidget {
  const AdvertisementCarousel({
    super.key,
    required this.advertisements,
    this.height = 188,
    this.autoSlideInterval = const Duration(seconds: 5),
  });

  final List<Advertisement> advertisements;
  final double height;
  final Duration autoSlideInterval;

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(AdvertisementCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.advertisements.length != widget.advertisements.length) {
      _currentPage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _restartAutoSlide();
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (widget.advertisements.length <= 1) return;
    _autoSlideTimer = Timer.periodic(widget.autoSlideInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % widget.advertisements.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _restartAutoSlide() {
    _autoSlideTimer?.cancel();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.advertisements.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.advertisements.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final ad = widget.advertisements[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AdBannerSlide(
                  ad: ad,
                  onTap: () => context.push('/ads/${ad.id}'),
                ),
              );
            },
          ),
        ),
        if (widget.advertisements.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.advertisements.length, (index) {
              final selected = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: selected ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.medicalBlue
                      : AppTheme.medicalBlue.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _AdBannerSlide extends StatelessWidget {
  const _AdBannerSlide({required this.ad, required this.onTap});

  final Advertisement ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ad.displayImageUrl;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  TabibImage(
                    imageUrl: ad.imageUrl ?? imageUrl,
                    thumbnailUrl: ad.imageThumbnailUrl,
                    fit: BoxFit.cover,
                    preferThumbnail: true,
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.medicalBlue,
                          AppTheme.medicalGreen,
                        ],
                      ),
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ad.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      if (ad.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          ad.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
