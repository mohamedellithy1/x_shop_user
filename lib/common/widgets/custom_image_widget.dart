import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_cache_manager.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/xmarket_images.dart';

class CustomImageWidget extends StatefulWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String placeholder;
  final Color? imageColor;
  final bool isRestaurant;
  final bool isFood;
  final Color? color;
  const CustomImageWidget(
      {super.key,
      required this.image,
      this.height,
      this.width,
      this.fit = BoxFit.cover,
      this.placeholder = '',
      this.imageColor,
      this.isRestaurant = false,
      this.isFood = false,
      this.color});

  @override
  State<CustomImageWidget> createState() => _CustomImageWidgetState();
}

class _CustomImageWidgetState extends State<CustomImageWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    String imageUrl = kIsWeb
        ? '${AppConstants.baseUrl}/image-proxy?url=${widget.image}'
        : widget.image;

    Widget placeholderWidget = CustomAssetImageWidget(
        widget.placeholder.isNotEmpty
            ? widget.placeholder
            : widget.isRestaurant
                ? XmarketImages.restaurantPlaceholder
                : widget.isFood
                    ? XmarketImages.foodPlaceholder
                    : XmarketImages.placeholderPng,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        color: widget.imageColor);

    if (widget.image.isEmpty || widget.image == 'null') {
      return placeholderWidget;
    }

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedScale(
        scale: _isHovered ? 1.2 : 1.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: CachedNetworkImage(
          cacheManager: CustomCacheManager.instance,
          color: widget.color,
          imageUrl: imageUrl,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          placeholder: (context, url) => placeholderWidget,
          errorWidget: (context, url, error) {
            print("🖼️ Image Error for $url: $error");
            return placeholderWidget;
          },
        ),
      ),
    );
  }
}
