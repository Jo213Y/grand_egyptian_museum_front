import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/button.dart';
import '../widgets/common_widgets.dart';
import '../utils/app_assets.dart';
import '../models/ticket_type.dart';
import '../models/selected_ticket.dart';
import '../services/api_service.dart';
import '../widgets/input_field.dart';
import 'home_screen.dart';

// ════════════════════════════════════════════════════════════════
// PAYMENT SCREEN
// ════════════════════════════════════════════════════════════════
class PaymentScreen extends StatefulWidget {
  final String visitDate;
  final List<SelectedTicket> tickets;
  final double totalPrice;
  final int? hallId;

  const PaymentScreen({
    super.key,
    required this.visitDate,
    required this.tickets,
    required this.totalPrice,
    this.hallId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  final _expCtrl  = TextEditingController();
  final _cvvCtrl  = TextEditingController();

  bool _loading = false;

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ApiService.createBooking(
        visitDate: widget.visitDate,
        hallId: widget.hallId,
        tickets: widget.tickets,
        paymentInfo: {
          'nameOnCard':     _nameCtrl.text,
          'cardNumber':     _cardCtrl.text,
          'expirationDate': _expCtrl.text,
          'securityCode':   _cvvCtrl.text,
        },
      );
    } catch (_) {
      // continue to DoneScreen even on error
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DoneScreen(
            visitDate: widget.visitDate,
            tickets: widget.tickets.where((t) => t.quantity > 0).toList(),
            totalPrice: widget.totalPrice,
          ),
        ),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GemAppBar(
        activePage: 'Ticket',
      ),
      body: GemBackground(
        imageAsset: AppAssets.bgMuseum,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "Book Your Visit",
                  style: AppTextStyles.goldTitle,
                ),

                const SizedBox(height: 20),

                LayoutBuilder(
                  builder: (_, c) {
                    final wide = c.maxWidth > 700;
                    return wide
                        ? Row(
                      children: [
                        Expanded(child: _order()),
                        const SizedBox(width: 20),
                        Expanded(child: _form()),
                      ],
                    )
                        : Column(
                      children: [
                        _order(),
                        const SizedBox(height: 20),
                        _form(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _order() {
    final selected = widget.tickets.where((t) => t.quantity > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Summary", style: AppTextStyles.heading4),
          const SizedBox(height: 15),
          Text(widget.visitDate, style: AppTextStyles.body),
          const SizedBox(height: 10),
          ...selected.map(
                (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${t.label} x${t.quantity}", style: AppTextStyles.body),
                  Text("\$${t.subtotal}", style: AppTextStyles.price),
                ],
              ),
            ),
          ),
          const Divider(color: AppColors.primaryLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: AppTextStyles.heading4),
              Text(
                "\$${widget.totalPrice.toInt()}",
                style: AppTextStyles.goldTitle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text("Payment", style: AppTextStyles.heading4),

            const SizedBox(height: 15),

            GemTextField(
              label: "Name on card",
              controller: _nameCtrl,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),

            const SizedBox(height: 10),

            GemTextField(
              label: "Card number",
              controller: _cardCtrl,
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: GemTextField(
                    label: "MM/YY",
                    controller: _expCtrl,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GemTextField(
                    label: "CVV",
                    controller: _cvvCtrl,
                    obscure: true,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            GemButton(
              label: "Pay \$${widget.totalPrice.toInt()}",
              onPressed: _pay,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// DONE SCREEN
// ════════════════════════════════════════════════════════════════
class DoneScreen extends StatelessWidget {
  final String visitDate;
  final List<SelectedTicket> tickets;
  final double totalPrice;

  const DoneScreen({
    super.key,
    required this.visitDate,
    required this.tickets,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossCount  = screenWidth > 900 ? 3 : screenWidth > 600 ? 2 : 1;
    final cols        = tickets.length >= crossCount ? crossCount : tickets.length;

    return Scaffold(
      body: GemBackground(
        imageAsset: AppAssets.bgMuseum,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.check_circle, color: Colors.green, size: 90),
              const SizedBox(height: 10),
              const Text("Booking Confirmed", style: AppTextStyles.goldTitle),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // ── Date card ──
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: AppDecorations.card,
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: AppColors.primaryLight),
                            const SizedBox(width: 8),
                            Text("Date: $visitDate",
                                style: AppTextStyles.body),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Tickets grid — 3 per row, centered ──
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: tickets.length >= crossCount
                                ? double.infinity
                                : cols * 220.0 + (cols - 1) * 12,
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: tickets.map((t) => SizedBox(
                              width: tickets.length >= crossCount
                                  ? (MediaQuery.of(context).size.width - 40 - (crossCount - 1) * 12) / crossCount
                                  : 220,
                              child: TicketCard(
                                ticket: t,
                                visitDate: visitDate,
                              ),
                            )).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: GemButton(
                  label: "Back Home",
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomeScreen()),
                          (_) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// TICKET CARD WIDGET
// ════════════════════════════════════════════════════════════════
class TicketCard extends StatefulWidget {
  final SelectedTicket ticket;
  final String visitDate;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.visitDate,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  late final String _code;

  @override
  void initState() {
    super.initState();
    _code = _generateCode();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    final suffix =
    List.generate(8, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'MUS-$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A00),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC8A96E).withOpacity(0.45),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildDetails(),
          _buildDivider(),
          _buildCodes(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "EGYPTIAN MUSEUM",
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Color(0xFFC8A96E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.ticket.label} Ticket",
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    color: Color(0xFFF5D896),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC8A96E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "x${widget.ticket.quantity}",
              style: const TextStyle(
                color: Color(0xFF1A0A00),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              _field("Ticket Type", widget.ticket.label),
              const SizedBox(width: 12),
              _field("Visit Date", widget.visitDate),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _field("Price Each", "\$${widget.ticket.price}"),
              const SizedBox(width: 12),
              _field("Total", "\$${widget.ticket.subtotal}"),
            ],
          ),
          const SizedBox(height: 12),
          _field("Ticket Code", _code, mono: true, full: true),
        ],
      ),
    );
  }

  Widget _field(
      String label,
      String value, {
        bool mono = false,
        bool full = false,
      }) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.2,
            color: Color(0xFFC8A96E),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFFF5D896),
            fontFamily: mono ? 'monospace' : null,
            letterSpacing: mono ? 1.0 : null,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return full
        ? SizedBox(width: double.infinity, child: child)
        : Expanded(child: child);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-8, 0),
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: AppColors.primaryCard,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (_, bc) => CustomPaint(
              size: Size(bc.maxWidth, 1),
              painter: _DashedLinePainter(),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(8, 0),
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: AppColors.primaryCard,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodes() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 44),
                  painter: _BarcodePainter(seed: _code.hashCode),
                ),
                const SizedBox(height: 4),
                Text(
                  _code,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.black54,
                    fontFamily: 'monospace',
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          QrImageView(
            data: _code,
            version: QrVersions.auto,
            size: 60,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xFF1A0A00),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFF1A0A00),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PAINTERS
// ════════════════════════════════════════════════════════════════

class _BarcodePainter extends CustomPainter {
  final int seed;
  const _BarcodePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1A0A00);
    final rnd = Random(seed);
    double x = 0;
    while (x < size.width) {
      final w = rnd.nextDouble() * 3 + 1;
      if (rnd.nextBool()) {
        canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      }
      x += w + rnd.nextDouble() * 2 + 0.5;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) => old.seed != seed;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8A96E).withOpacity(0.4)
      ..strokeWidth = 1;
    const dashW = 6.0;
    const gapW  = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}