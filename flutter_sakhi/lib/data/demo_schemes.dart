/// Demo/fallback government schemes data.
///
/// Shown when the backend API or database is unreachable (offline mode).
/// Contains three well-known Indian agricultural schemes: PM-KISAN,
/// PM Fasal Bima Yojana, and Kisan Credit Card.
import 'package:sakhi_ai/models/govt_scheme.dart';

/// Bundled list of demo [GovtScheme] entries used as an offline fallback.
const List<GovtScheme> kDemoSchemes = [
  GovtScheme(
    id: 'pm-kisan',
    name: 'PM-KISAN',
    summary: '₹6,000/year direct income support for farmer families.',
    state: 'All India',
    eligibility: 'Small & marginal farmers with land records',
  ),
  GovtScheme(
    id: 'pmfby',
    name: 'PM Fasal Bima Yojana',
    summary: 'Crop insurance at low premium with government subsidy.',
    state: 'All India',
    eligibility: 'Farmers growing notified crops',
  ),
  GovtScheme(
    id: 'kcc',
    name: 'Kisan Credit Card',
    summary: 'Easy credit for farming needs at subsidized interest.',
    state: 'All India',
    eligibility: 'Farmers, tenant farmers, SHGs',
  ),
];
