import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../services/product_api_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/mobile/product_card_mobile.dart';
import '../../widgets/web/product_card_web.dart';

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _ratingController = TextEditingController(text: '5.0');
  final _soldController = TextEditingController(text: '0');
  final _locationController = TextEditingController();
  final _promoTextController = TextEditingController();
  final _soldLabelController = TextEditingController();

  bool _freeShipping = false;
  String _metaIcon = 'none';
  bool _isOfficial = false;
  bool _isPowerShop = false;
  bool _usePriceBadge = false;
  bool _showDiscountBesidePrice = false;
  bool _webUseDiscountPrice = false;

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _discountController.dispose();
    _ratingController.dispose();
    _soldController.dispose();
    _locationController.dispose();
    _promoTextController.dispose();
    _soldLabelController.dispose();
    super.dispose();
  }

  int _parsePrice(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  String _formatRupiahInput(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final amount = int.parse(digits);
    return CurrencyFormatter.format(amount).replaceAll('Rp', '').trim();
  }

  bool get _isWebNormalPriceMode => kIsWeb && !_webUseDiscountPrice;

  int get _effectivePrice => _parsePrice(_priceController.text);

  int get _effectiveOriginalPrice => _isWebNormalPriceMode
      ? _effectivePrice
      : _parsePrice(_originalPriceController.text);

  int get _effectiveDiscount =>
      _isWebNormalPriceMode ? 0 : int.tryParse(_discountController.text) ?? 0;

  bool get _effectiveUsePriceBadge =>
      _isWebNormalPriceMode ? false : _usePriceBadge;

  bool get _effectiveShowDiscountBesidePrice =>
      _isWebNormalPriceMode ? false : _showDiscountBesidePrice;

  ProductModel get _previewProduct {
    return ProductModel(
      id: 'preview',
      name: _nameController.text.isEmpty ? 'Nama Produk' : _nameController.text,
      description: _descController.text.isEmpty
          ? 'Deskripsi produk'
          : _descController.text,
      imagePath: '',
      imageUrl: _imageBytes != null ? null : null,
      price: _effectivePrice,
      originalPrice: _effectiveOriginalPrice,
      rating: double.tryParse(_ratingController.text) ?? 5.0,
      sold: int.tryParse(_soldController.text) ?? 0,
      location: _locationController.text.isEmpty
          ? 'Lokasi'
          : _locationController.text,
      discount: _effectiveDiscount,
      isOfficial: _isOfficial,
      freeShipping: _freeShipping,
      promoText: _promoTextController.text,
      soldLabel: _soldLabelController.text.isEmpty
          ? null
          : _soldLabelController.text,
      usePriceBadge: _effectiveUsePriceBadge,
      metaIcon: ProductModel.parseMetaIconPublic(_metaIcon),
      isPowerShop: _isPowerShop,
      showDiscountBesidePrice: _effectiveShowDiscountBesidePrice,
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      // Validate file size (5MB)
      if (bytes.length > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran file maksimal 5MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
        _uploadError = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageBytes == null) {
      setState(() => _uploadError = 'Foto produk wajib diunggah');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      final price = _effectivePrice;
      final originalPrice = _effectiveOriginalPrice;
      final discount = _effectiveDiscount;

      final fields = <String, String>{
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': price.toString(),
        'original_price': originalPrice.toString(),
        'discount': discount.toString(),
        'rating': _ratingController.text.trim(),
        'sold': _soldController.text.trim().isEmpty
            ? '0'
            : _soldController.text.trim(),
        'location': _locationController.text.trim(),
        'promo_text': _promoTextController.text.trim(),
        'free_shipping': _freeShipping.toString(),
        'meta_icon': _metaIcon,
        'is_official': _isOfficial.toString(),
        'is_power_shop': _isPowerShop.toString(),
        'use_price_badge': _effectiveUsePriceBadge.toString(),
        'show_discount_beside': _effectiveShowDiscountBesidePrice.toString(),
      };

      if (_soldLabelController.text.trim().isNotEmpty) {
        fields['sold_label'] = _soldLabelController.text.trim();
      }

      final product = await ProductApiService.createProduct(
        fields: fields,
        imagePath: '',
        imageBytes: _imageBytes!,
        imageName: _imageName ?? 'product.jpg',
      );

      if (mounted) {
        context.read<ProductProvider>().addProduct(product);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil diunggah! 🎉'),
            backgroundColor: AppColors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _uploadError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _originalPriceController.clear();
    _discountController.clear();
    _ratingController.text = '5.0';
    _soldController.text = '0';
    _locationController.clear();
    _promoTextController.clear();
    _soldLabelController.clear();
    setState(() {
      _freeShipping = false;
      _metaIcon = 'none';
      _isOfficial = false;
      _isPowerShop = false;
      _usePriceBadge = false;
      _showDiscountBesidePrice = false;
      _webUseDiscountPrice = false;
      _imageBytes = null;
      _imageName = null;
      _uploadError = null;
    });
  }

  void _setWebUseDiscountPrice(bool value) {
    setState(() {
      _webUseDiscountPrice = value;
      if (value) {
        _usePriceBadge = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppBreakpoints.desktop;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Upload Produk',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        shadowColor: Colors.black12,
        actions: [
          TextButton.icon(
            onPressed: _resetForm,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: _buildForm(),
              ),
            ),
            Container(width: 1, color: AppColors.border),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: _buildPreviewSection(isWeb: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildForm(),
          const SizedBox(height: 24),
          _buildPreviewSection(isWeb: false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image picker
          _buildImagePicker(),
          const SizedBox(height: 20),

          // Name
          _buildLabel('Nama Produk *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Masukkan nama produk'),
            validator: (v) =>
                v == null || v.trim().length < 3 ? 'Minimal 3 karakter' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Description
          _buildLabel('Deskripsi Produk *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descController,
            decoration: _inputDecoration('Masukkan deskripsi produk'),
            maxLines: 3,
            validator: (v) => v == null || v.trim().length < 10
                ? 'Minimal 10 karakter'
                : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          if (kIsWeb) ...[
            _buildWebPriceModeSelector(),
            const SizedBox(height: 16),
          ],

          // Price row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(
                      _isWebNormalPriceMode
                          ? 'Harga Normal *'
                          : kIsWeb
                          ? 'Harga Setelah Diskon *'
                          : 'Harga *',
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _priceController,
                      decoration: _inputDecoration('0', prefix: 'Rp '),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        final price = _parsePrice(v ?? '');
                        return price < 100 ? 'Minimal Rp100' : null;
                      },
                      onChanged: (v) {
                        final formatted = _formatRupiahInput(v);
                        if (formatted != v) {
                          _priceController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              if (!_isWebNormalPriceMode) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(
                        kIsWeb
                            ? 'Harga Normal / Sebelum Diskon *'
                            : 'Harga Asli *',
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _originalPriceController,
                        decoration: _inputDecoration('0', prefix: 'Rp '),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          final price = _parsePrice(v ?? '');
                          return price < 100 ? 'Minimal Rp100' : null;
                        },
                        onChanged: (v) {
                          final formatted = _formatRupiahInput(v);
                          if (formatted != v) {
                            _originalPriceController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: formatted.length,
                              ),
                            );
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Discount & Rating row
          Row(
            children: [
              if (!_isWebNormalPriceMode) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Diskon (%)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _discountController,
                        decoration: _inputDecoration('0'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final d = int.tryParse(v) ?? 0;
                          return d > 100 ? 'Maksimal 100%' : null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Rating'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _ratingController,
                      decoration: _inputDecoration('5.0'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final r = double.tryParse(v ?? '') ?? 0;
                        return r < 0 || r > 5 ? '0-5' : null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sold & Location row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Terjual'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _soldController,
                      decoration: _inputDecoration('0'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Lokasi / Nama Toko *'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration('Jakarta'),
                      validator: (v) => v == null || v.trim().length < 2
                          ? 'Wajib diisi'
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Promo text
          _buildLabel('Teks Promo'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _promoTextController,
            decoration: _inputDecoration('Hemat s.d 10% Pakai Bonus'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Sold label
          _buildLabel('Label Terjual (opsional)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _soldLabelController,
            decoration: _inputDecoration('Contoh: 10rb+'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Toggles
          _buildSwitchTile(
            'Gratis Ongkir',
            _freeShipping,
            (v) => setState(() => _freeShipping = v),
          ),
          _buildSwitchTile(
            'Official Store',
            _isOfficial,
            (v) => setState(() => _isOfficial = v),
          ),
          _buildSwitchTile(
            'Power Shop',
            _isPowerShop,
            (v) => setState(() => _isPowerShop = v),
          ),
          if (!_isWebNormalPriceMode) ...[
            _buildSwitchTile(
              'Badge Harga',
              _usePriceBadge,
              (v) => setState(() => _usePriceBadge = v),
            ),
            if (!kIsWeb)
              _buildSwitchTile(
                'Diskon Di Samping Harga',
                _showDiscountBesidePrice,
                (v) => setState(() => _showDiscountBesidePrice = v),
              ),
          ],
          const SizedBox(height: 16),

          // Meta icon dropdown
          _buildLabel('Status Ikon Toko'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _metaIcon,
            decoration: _inputDecoration(''),
            items: const [
              DropdownMenuItem(value: 'none', child: Text('Tanpa Ikon')),
              DropdownMenuItem(
                value: 'officialStore',
                child: Text('Official Store'),
              ),
              DropdownMenuItem(
                value: 'powerMerchant',
                child: Text('Power Merchant'),
              ),
              DropdownMenuItem(value: 'legacy', child: Text('Legacy')),
            ],
            onChanged: (v) => setState(() => _metaIcon = v ?? 'none'),
          ),
          const SizedBox(height: 24),

          // Error message
          if (_uploadError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _uploadError!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Submit button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Upload Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebPriceModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Tipe Harga Web'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPriceModeButton(
                icon: Icons.sell_outlined,
                title: 'Harga Normal',
                subtitle: 'Tanpa diskon, harga hitam',
                selected: !_webUseDiscountPrice,
                onTap: () => _setWebUseDiscountPrice(false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriceModeButton(
                icon: Icons.local_offer_outlined,
                title: 'Harga Diskon',
                subtitle: 'Pakai diskon produk',
                selected: _webUseDiscountPrice,
                onTap: () => _setWebUseDiscountPrice(true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceModeButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final borderColor = selected ? AppColors.green : AppColors.border;
    final iconColor = selected ? AppColors.green : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FFF5) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF23211E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _uploadError != null && _imageBytes == null
                ? Colors.red
                : AppColors.border,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
        child: _imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_imageBytes!, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _imageBytes = null;
                              _imageName = null;
                            });
                          },
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _imageName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: _uploadError != null && _imageBytes == null
                        ? Colors.red.withValues(alpha: 0.5)
                        : const Color(0xFFBDBDBD),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap untuk memilih foto produk',
                    style: TextStyle(
                      color: _uploadError != null && _imageBytes == null
                          ? Colors.red
                          : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPEG, PNG, WebP • Maks 5MB',
                    style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 11),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPreviewSection({required bool isWeb}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Kartu Produk',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF23211E),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pratinjau tampilan produk di katalog',
          style: TextStyle(fontSize: 12, color: Color(0xFF828085)),
        ),
        const SizedBox(height: 16),
        if (isWeb)
          SizedBox(
            width: 200,
            child: _PreviewWebCard(
              product: _previewProduct,
              imageBytes: _imageBytes,
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: _PreviewMobileCard(
              product: _previewProduct,
              imageBytes: _imageBytes,
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF344054),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildSwitchTile(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.green,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}

// Preview card for web that shows selected image from memory
class _PreviewWebCard extends StatelessWidget {
  final ProductModel product;
  final Uint8List? imageBytes;

  const _PreviewWebCard({required this.product, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      // We can't directly use ProductCardWeb with memory image, so build a simplified preview
      return _PreviewCardContent(
        product: product,
        imageWidget: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.memory(imageBytes!, fit: BoxFit.cover),
          ),
        ),
        isWeb: true,
      );
    }
    return ProductCardWeb(product: product);
  }
}

// Preview card for mobile
class _PreviewMobileCard extends StatelessWidget {
  final ProductModel product;
  final Uint8List? imageBytes;

  const _PreviewMobileCard({required this.product, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return _PreviewCardContent(
        product: product,
        imageWidget: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.memory(imageBytes!, fit: BoxFit.cover),
          ),
        ),
        isWeb: false,
      );
    }
    return ProductCardMobile(product: product);
  }
}

// Simplified preview card that accepts custom image widget
class _PreviewCardContent extends StatelessWidget {
  final ProductModel product;
  final Widget imageWidget;
  final bool isWeb;

  const _PreviewCardContent({
    required this.product,
    required this.imageWidget,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            imageWidget,
            if (product.discount > 0)
              Positioned(
                top: isWeb ? 8 : 0,
                right: isWeb ? null : 0,
                left: isWeb ? -5 : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB495C),
                    borderRadius: isWeb
                        ? BorderRadius.circular(5)
                        : const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            topRight: Radius.circular(7),
                          ),
                  ),
                  child: Text(
                    '${product.discount}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF322F2B),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(product.price),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isWeb ? 16 : 18,
            fontWeight: FontWeight.w800,
            color: isWeb ? const Color(0xFF23211E) : const Color(0xFFD81B60),
            height: 1.2,
          ),
        ),
        if (product.promoText.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            product.promoText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFF8614),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.star, size: 15, color: Color(0xFFFFCF01)),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                '${product.rating.toStringAsFixed(1)} · ${product.sold} terjual',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF828085),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          product.location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF828085),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
