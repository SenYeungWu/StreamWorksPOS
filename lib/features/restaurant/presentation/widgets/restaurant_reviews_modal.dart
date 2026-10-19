import 'package:flutter/material.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/core/widgets/rating_stars.dart';

class ReviewItem {
  final String author;
  final String date;
  final int rating;
  final String comment;

  const ReviewItem({
    required this.author,
    required this.date,
    required this.rating,
    required this.comment,
  });
}

Future<void> showRestaurantReviewsModal(
  BuildContext context,
  Restaurant restaurant,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) => RestaurantReviewsModal(restaurant: restaurant),
  );
}

class RestaurantReviewsModal extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantReviewsModal({super.key, required this.restaurant});

  @override
  State<RestaurantReviewsModal> createState() => _RestaurantReviewsModalState();
}

class _RestaurantReviewsModalState extends State<RestaurantReviewsModal> {
  late List<ReviewItem> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = _generateDefaultReviews(widget.restaurant);
  }

  List<ReviewItem> _generateDefaultReviews(Restaurant r) {
    return const [
      ReviewItem(
        author: 'Sarah L.',
        date: '2 days ago',
        rating: 5,
        comment:
            'Outstanding quality! The ingredients were remarkably fresh and delivery arrived steaming hot. Best dining experience in the neighborhood!',
      ),
      ReviewItem(
        author: 'David K.',
        date: '5 days ago',
        rating: 5,
        comment:
            'Generous portions and incredible depth of flavor. Packaged with care, no leaks or spills. Will definitely reorder soon.',
      ),
      ReviewItem(
        author: 'Elena M.',
        date: '1 week ago',
        rating: 4,
        comment:
            'Very consistent culinary execution and courteous delivery courier. Loved every bite of the signature dishes.',
      ),
      ReviewItem(
        author: 'Marcus W.',
        date: '2 weeks ago',
        rating: 5,
        comment:
            'Authentic flavors and top-tier presentation. Highly recommended for anyone craving a genuinely delicious meal.',
      ),
    ];
  }

  void _openWriteReviewDialog() {
    int selectedRating = 5;
    final textController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.rate_review,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8.0),
                  const Text(
                    'Write a Review',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rating for ${widget.restaurant.name}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return IconButton(
                          icon: Icon(
                            starValue <= selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32.0,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = starValue;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12.0),
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Share your dining experience, flavors, or delivery...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    final comment = textController.text.trim();
                    if (comment.isNotEmpty) {
                      setState(() {
                        _reviews.insert(
                          0,
                          ReviewItem(
                            author: 'You',
                            date: 'Just now',
                            rating: selectedRating,
                            comment: comment,
                          ),
                        );
                      });
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you! Your review has been submitted.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit Review'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12.0),
              Container(
                width: 40.0,
                height: 5.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reviews & Ratings',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.restaurant.name,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1.0),
              // Scrollable Review Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  children: [
                    // Summary Rating Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                '${widget.restaurant.rating}.0',
                                style: const TextStyle(
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              RatingStars(widget.restaurant.rating),
                              const SizedBox(height: 4.0),
                              Text(
                                '${_reviews.length * 35 + 2} ratings',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24.0),
                          Expanded(
                            child: Column(
                              children: [
                                _buildRatingBar(5, 0.85, primaryColor),
                                _buildRatingBar(4, 0.11, primaryColor),
                                _buildRatingBar(3, 0.03, primaryColor),
                                _buildRatingBar(2, 0.01, primaryColor),
                                _buildRatingBar(1, 0.00, primaryColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Write Review Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text(
                        'Write a Review',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _openWriteReviewDialog,
                    ),
                    const SizedBox(height: 20.0),
                    // Reviews List Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Verified Reviews (${_reviews.length})',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Most Recent',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    // Review Items
                    ..._reviews.map((r) => _buildReviewCard(r, primaryColor)),
                    const SizedBox(height: 30.0),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingBar(int stars, double ratio, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '$stars★',
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6.0),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewItem review, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.0,
                backgroundColor: primaryColor.withValues(alpha: 0.15),
                child: Text(
                  review.author.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Icon(
                          Icons.verified,
                          size: 14.0,
                          color: Colors.green[600],
                        ),
                      ],
                    ),
                    Text(
                      review.date,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              RatingStars(review.rating),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14.0,
              height: 1.35,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
