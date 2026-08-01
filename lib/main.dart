import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini
import 'firebase_options.dart';

import 'app.dart';
import 'shared/providers/theme_provider.dart';
import 'core/utils/date_formatter.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/transactions/providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Aktifkan Offline Persistence (Cache)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await DateFormatter.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Daftarkan Provider Transaksi di sini
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const SmartBudgetApp(),
    ),
  );
}