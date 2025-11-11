class SubscriptionPlan {
  final String id;
  final String name;
  final String duration;
  final int price;
  final String priceDisplay;
  final int durationDays;
  final String description;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.priceDisplay,
    required this.durationDays,
    required this.description,
    this.isPopular = false,
  });

  static List<SubscriptionPlan> getPlans() {
    return [
      SubscriptionPlan(
        id: 'weekly',
        name: 'Weekly',
        duration: '7 Days',
        price: 49,
        priceDisplay: '₹49',
        durationDays: 7,
        description: 'Perfect for trying premium features',
        isPopular: false,
      ),
      SubscriptionPlan(
        id: 'monthly',
        name: 'Monthly',
        duration: '30 Days',
        price: 99,
        priceDisplay: '₹99',
        durationDays: 30,
        description: 'Most popular - Best value!',
        isPopular: true,
      ),
      SubscriptionPlan(
        id: 'yearly',
        name: 'Yearly',
        duration: '365 Days',
        price: 1000,
        priceDisplay: '₹1,000',
        durationDays: 365,
        description: 'Save 75% - Best deal of the year!',
        isPopular: false,
      ),
    ];
  }
}
