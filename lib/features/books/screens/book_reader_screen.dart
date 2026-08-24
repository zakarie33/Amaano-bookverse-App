import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/continue_content_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/auth_guard.dart';
import '../../cart/cart_provider.dart';
import '../../cart/screens/checkout_screen.dart';
import '../models/content_model.dart';

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({super.key, this.contentId});

  final int? contentId;

  static const String routeName = '/book-reader';

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final _api = ApiService();
  final _secureStorage = SecureStorage();
  bool _loading = true;
  String? _error;
  ContentModel? _content;
  Map<String, String>? _pdfHeaders;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ensureLoggedIn(context)) {
        Navigator.of(context).pop();
        return;
      }
      _load();
    });
  }

  int _resolveId(BuildContext context) {
    if (widget.contentId != null) return widget.contentId!;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ContentModel) return args.id;
    if (args is int) return args;
    return 0;
  }

  Future<void> _load() async {
    final id = _resolveId(context);
    if (id <= 0) {
      setState(() {
        _loading = false;
        _error = 'Invalid book.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.get(
        ApiConstants.contentDetails,
        query: {'id': '$id'},
      );
      final raw = data is Map ? (data['content'] ?? data['data']) : null;
      if (raw is! Map) throw Exception('Book not found.');
      final content = ContentModel.fromJson(Map<String, dynamic>.from(raw));

      if (content.isPendingPayment) {
        if (!mounted) return;
        setState(() {
          _content = content;
          _loading = false;
          _error = 'pending_approval';
        });
        return;
      }

      if (!content.userCanAccessContent) {
        if (!mounted) return;
        setState(() {
          _content = content;
          _loading = false;
          _error = 'purchase_required';
        });
        return;
      }

      if (!content.canRead && content.hasPdf != true) {
        throw Exception('No readable file is available for this book.');
      }

      final headers = <String, String>{};
      final token = await _secureStorage.getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      if (!mounted) return;
      setState(() {
        _content = content;
        _pdfHeaders = headers.isEmpty ? null : headers;
        _loading = false;
      });

      final auth = context.read<AuthService>();
      if (auth.isLoggedIn && auth.user != null) {
        await ContinueContentService.instance
            .saveReading(auth.user!.id, content);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _buyNow() {
    final content = _content;
    if (content == null) return;
    requireLogin(context, () {
      context.read<CartProvider>().addItem(content);
      Navigator.of(context).pushNamed(CheckoutScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _content?.title ?? 'Reader';
    final id = _resolveId(context);

    return Scaffold(
      backgroundColor: AppColors.espressoDeep,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.espresso,
        foregroundColor: AppColors.tortilla,
      ),
      body: _buildBody(id),
    );
  }

  Widget _buildBody(int contentId) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.caramel),
      );
    }

    if (_error == 'pending_approval') {
      return _pendingApproval();
    }

    if (_error == 'purchase_required') {
      return _purchaseRequired();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.caramel),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.tortilla),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.caramel,
                  foregroundColor: AppColors.espressoDeep,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SfPdfViewer.network(
      ApiConstants.readBookUrl(contentId),
      headers: _pdfHeaders,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableDoubleTapZooming: true,
    );
  }

  Widget _pendingApproval() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top_rounded,
                size: 56, color: AppColors.caramel),
            const SizedBox(height: 16),
            Text(
              _content?.title ?? 'This book',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.tortilla,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Waiting for Admin Approval',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.tortilla,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your payment is being reviewed. You can read this book here once approved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _purchaseRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: AppColors.caramel),
            const SizedBox(height: 16),
            Text(
              _content?.title ?? 'This book',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.tortilla,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Purchase required',
              style: TextStyle(color: AppColors.mutedText, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete checkout and wait for admin approval to read this book in the app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText, height: 1.45),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _buyNow,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Buy Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caramel,
                foregroundColor: AppColors.espressoDeep,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
