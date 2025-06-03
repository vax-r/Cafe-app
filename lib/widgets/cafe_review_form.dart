import 'package:flutter/material.dart';

class StarRatingInput extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double size;
  final Color color;

  const StarRatingInput({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 32,
    this.color = Colors.amber,
  });

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  void _onStarTapped(int index) {
    setState(() {
      _rating = index.toDouble();
    });
    widget.onRatingChanged(_rating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            _rating >= index + 1 ? Icons.star : Icons.star_border,
            color: widget.color,
            size: widget.size,
          ),
          onPressed: () => _onStarTapped(index + 1),
          splashRadius: widget.size * 0.6,
        );
      }),
    );
  }
}

// 然後修改 CafeReviewForm：
class CafeReviewForm extends StatefulWidget {
  final String cafeName;
  final void Function(String text, double rating) onSubmit;

  const CafeReviewForm({
    super.key,
    required this.cafeName,
    required this.onSubmit,
  });

  @override
  State<CafeReviewForm> createState() => _CafeReviewFormState();
}

class _CafeReviewFormState extends State<CafeReviewForm> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Rating: ${_rating.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16),
            ),
            StarRatingInput(
              initialRating: _rating,
              onRatingChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Review: ${widget.cafeName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Write your review',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onSubmit(_reviewController.text.trim(), _rating);
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
