import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/api_result.dart';
import '../../../core/models/payment_method_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/osm_location_picker.dart';
import '../cart_provider.dart';
import '../../library/screens/my_purchases_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  static const String routeName = '/checkout';

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _deliveryNoteController = TextEditingController();
  final _txController = TextEditingController();
  final _noteController = TextEditingController();

  double? _locationLat;
  double? _locationLng;

  bool _processing = false;
  bool _loadingMethods = true;
  List<PaymentMethodModel> _methods = [];
  int? _selectedMethodId;
  String? _error;
  String _fulfillment = 'pickup';
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _loadMethods();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = context.read<CartProvider>();
      if (cart.items.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final auth = context.read<AuthService>();
    _nameController.text = auth.user?.name ?? '';
    _emailController.text = auth.user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _landmarkController.dispose();
    _deliveryNoteController.dispose();
    _txController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadMethods() async {
    setState(() {
      _loadingMethods = true;
      _error = null;
    });
    try {
      final data = await _api.get(ApiConstants.paymentMethods);
      final list = data is Map ? data['payment_methods'] : null;
      if (!mounted) return;
      setState(() {
        _methods = list is List
            ? list
                .whereType<Map>()
                .map((e) =>
                    PaymentMethodModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [];
        _loadingMethods = false;
        if (_methods.isNotEmpty) {
          _selectedMethodId = _methods.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMethods = false;
        _error = e.toString();
      });
    }
  }

  PaymentMethodModel? get _selectedMethod {
    if (_selectedMethodId == null) return null;
    for (final m in _methods) {
      if (m.id == _selectedMethodId) return m;
    }
    return null;
  }

  Future<void> _copyAccountNumber(String number) async {
    await Clipboard.setData(ClipboardData(text: number));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account number copied')),
    );
  }

  Future<void> _pickLocationOnMap() async {
    LatLng? initial;
    if (_locationLat != null && _locationLng != null) {
      initial = LatLng(_locationLat!, _locationLng!);
    }
    final picked = await OsmLocationPicker.show(context, initial: initial);
    if (!mounted || picked == null) return;
    setState(() {
      _locationLat = picked.latitude;
      _locationLng = picked.longitude;
    });
  }

  void _clearMapLocation() {
    setState(() {
      _locationLat = null;
      _locationLng = null;
    });
  }

  String _buildOrderNote() {
    final parts = <String>[];
    if (_fulfillment == 'delivery') {
      final landmark = _landmarkController.text.trim();
      if (landmark.isNotEmpty) parts.add('Landmark: $landmark');
      final deliveryNote = _deliveryNoteController.text.trim();
      if (deliveryNote.isNotEmpty) parts.add('Delivery note: $deliveryNote');
    }
    final paymentNote = _noteController.text.trim();
    if (paymentNote.isNotEmpty) parts.add('Payment note: $paymentNote');
    return parts.join('\n');
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a payment method')),
      );
      return;
    }

    setState(() => _processing = true);
    try {
      final ids = cart.items.map((i) => i.content.id).toList();
      final result = await _api.post(
        ApiConstants.cartCheckout,
        body: {
          'items': ids,
          'customer_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'fulfillment_type': _fulfillment,
          'delivery_address': _fulfillment == 'delivery'
              ? _addressController.text.trim()
              : null,
          'delivery_city':
              _fulfillment == 'delivery' ? _cityController.text.trim() : null,
          'location_lat':
              _fulfillment == 'delivery' ? _locationLat : null,
          'location_lng':
              _fulfillment == 'delivery' ? _locationLng : null,
          'payment_method_id': _selectedMethodId,
          'transaction_id': _txController.text.trim(),
          'note': _buildOrderNote(),
        },
      );
      final apiResult = result is Map<String, dynamic>
          ? ApiResult.fromJson(result)
          : const ApiResult(success: true);
      cart.clear();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cream,
          title: const Text(
            'Payment request submitted',
            style: TextStyle(color: _bodyText, fontWeight: FontWeight.w700),
          ),
          content: Text(
            apiResult.message ??
                'Admin will review your payment. Approved books will appear in your library.',
            style: const TextStyle(color: _mutedBodyText, height: 1.45),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushNamedAndRemoveUntil(
                  MyPurchasesScreen.routeName,
                  (route) => route.isFirst,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caramel,
                foregroundColor: AppColors.espressoDeep,
              ),
              child: const Text('My Purchases'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  static const _bodyText = AppColors.espresso;
  static const _mutedBodyText = AppColors.textOnCardMuted;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currency = NumberFormat.simpleCurrency();
    final method = _selectedMethod;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: _bodyText,
              displayColor: _bodyText,
            ),
        iconTheme: const IconThemeData(color: _bodyText),
      ),
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.espresso,
        foregroundColor: AppColors.tortilla,
      ),
      body: cart.items.isEmpty
          ? _emptyCart()
          : _loadingMethods
          ? const Center(child: CircularProgressIndicator(color: AppColors.caramel))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_error != null) _banner(_error!, isError: true),
                  if (_methods.isEmpty && _error == null)
                    _banner(
                      'No payment methods are available. Please contact support.',
                      isError: true,
                    ),
                  _sectionTitle('Your details'),
                  const SizedBox(height: 8),
                  _field(_nameController, 'Full name', validator: (v) {
                    if (v == null || v.trim().length < 3) {
                      return 'Enter your full name';
                    }
                    return null;
                  }),
                  if (_fulfillment == 'pickup')
                    _field(_phoneController, 'Phone number',
                        keyboard: TextInputType.phone, validator: (v) {
                      if (v == null || v.trim().length < 7) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    }),
                  _field(_emailController, 'Email', keyboard: TextInputType.emailAddress,
                      validator: (v) {
                    if (v == null || !v.contains('@')) return 'Enter a valid email';
                    return null;
                  }),
                  const SizedBox(height: 16),
                  _sectionTitle('Order option'),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'pickup', label: Text('Pickup')),
                      ButtonSegment(value: 'delivery', label: Text('Delivery')),
                    ],
                    selected: {_fulfillment},
                    onSelectionChanged: (s) => setState(() {
                      _fulfillment = s.first;
                      if (_fulfillment == 'pickup') {
                        _locationLat = null;
                        _locationLng = null;
                      }
                    }),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? AppColors.espressoDeep
                            : AppColors.espresso,
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? AppColors.caramel
                            : AppColors.cream,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_fulfillment == 'pickup')
                    Card(
                      color: AppColors.cream,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Pick up your order at the BookVerse office after payment is approved. '
                          'We will contact you when ready.',
                          style: TextStyle(color: _mutedBodyText, height: 1.45),
                        ),
                      ),
                    )
                  else ...[
                    _sectionTitle('Delivery location'),
                    const SizedBox(height: 8),
                    _field(_cityController, 'City / area', validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'City / area is required';
                      }
                      return null;
                    }),
                    _field(_addressController, 'Delivery address', maxLines: 2,
                        validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Delivery address is required';
                      }
                      return null;
                    }),
                    _field(_landmarkController, 'Nearest landmark (optional)'),
                    _field(_phoneController, 'Phone number',
                        keyboard: TextInputType.phone, validator: (v) {
                      if (v == null || v.trim().length < 7) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    }),
                    _field(_deliveryNoteController, 'Extra note (optional)',
                        maxLines: 2),
                    if (_locationLat != null && _locationLng != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.pin_drop_rounded,
                                size: 18, color: AppColors.caramelDark),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Map: ${_locationLat!.toStringAsFixed(5)}, '
                                '${_locationLng!.toStringAsFixed(5)}',
                                style: const TextStyle(
                                  color: _mutedBodyText,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _clearMapLocation,
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: _pickLocationOnMap,
                      icon: const Icon(Icons.map_outlined),
                      label: Text(
                        _locationLat == null
                            ? 'Pick location on map (optional)'
                            : 'Change map location',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _bodyText,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Uses OpenStreetMap — no Google API key required.',
                        style: TextStyle(
                          color: _mutedBodyText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _sectionTitle('Order summary'),
                  Card(
                    color: AppColors.cream,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ...cart.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.content.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.espresso,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    currency.format(item.lineTotal),
                                    style: const TextStyle(
                                      color: _bodyText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${cart.itemCount} item(s)',
                                style: const TextStyle(
                                  color: _bodyText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                currency.format(cart.subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: _bodyText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _fulfillment == 'delivery' ? 'Delivery selected' : 'Pickup selected',
                            style: const TextStyle(color: _mutedBodyText),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your payment will be reviewed by admin before library access is granted.',
                            style: TextStyle(
                              color: _mutedBodyText,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Payment method'),
                  ..._methods.map(_methodTile),
                  if (method != null) ...[
                    const SizedBox(height: 8),
                    Card(
                      color: AppColors.cream,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(method.methodName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.espresso)),
                            Text('Account: ${method.accountName}',
                                style: const TextStyle(color: _mutedBodyText)),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(method.accountNumber,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _bodyText)),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _copyAccountNumber(method.accountNumber),
                                  icon: const Icon(Icons.copy_rounded),
                                ),
                              ],
                            ),
                            if (method.instructions != null)
                              Text(method.instructions!,
                                  style: const TextStyle(
                                      color: _mutedBodyText, height: 1.4)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _field(_txController, 'Transaction / reference ID', validator: (v) {
                    if (v == null || v.trim().length < 3) {
                      return 'Enter transaction ID (min 3 characters)';
                    }
                    return null;
                  }),
                  _field(_noteController, 'Note (optional)', maxLines: 2),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Submit Payment Request',
                    loading: _processing,
                    onPressed:
                        cart.items.isEmpty || _methods.isEmpty ? null : _placeOrder,
                  ),
                ],
              ),
            ),
    ),
    );
  }

  Widget _emptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 56, color: AppColors.caramelDark),
            const SizedBox(height: 16),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: _bodyText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caramel,
                foregroundColor: AppColors.espressoDeep,
              ),
              child: const Text('Browse books'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: _bodyText,
          fontSize: 16,
        ),
      );

  Widget _banner(String message, {required bool isError}) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isError ? AppColors.danger : AppColors.success)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message,
            style: TextStyle(
                color: isError ? AppColors.danger : AppColors.success)),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    const labelColor = _bodyText;
    const hintColor = _mutedBodyText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: labelColor, fontWeight: FontWeight.w600),
          hintStyle: const TextStyle(color: hintColor),
          filled: true,
          fillColor: AppColors.cream,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.softBorder, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.caramelDark, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _methodTile(PaymentMethodModel m) {
    final selected = _selectedMethodId == m.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? AppColors.caramel.withValues(alpha: 0.2)
            : AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => setState(() => _selectedMethodId = m.id),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.caramel : AppColors.tortillaAlt,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: AppColors.caramelDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.methodName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: _bodyText)),
                      Text(m.accountNumber,
                          style: const TextStyle(
                              fontSize: 12, color: _mutedBodyText)),
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
