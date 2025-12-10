import 'package:dio/dio.dart';
import '../models/kost_model.dart';
import '../models/service_model.dart';

class CatalogProvider {
  final Dio _dio;

  CatalogProvider() : _dio = Dio() {
    _dio.options.baseUrl = 'https://api.rajakost.com/v1';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<Map<String, dynamic>> fetchAllData() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockKosts = [
        KostModel(
          id: '1',
          name: 'Kamar Single Fan',
          type: 'single_fan',
          price: 700000,
          description: 'Kamar kost dengan kipas angin, ukuran 3x3 meter',
          images: [
            'https://picsum.photos/seed/kost1/400/300.jpg',
            'https://picsum.photos/seed/kost1_2/400/300.jpg'
          ],
          facilities: ['Kasur', 'Lemari', 'Meja Belajar', 'Kipas Angin'],
          location: 'Jl. Tegalgondo No. 123, Malang',
          rating: 4.2,
          available: true,
        ),
        KostModel(
          id: '2',
          name: 'Kamar Single AC',
          type: 'single_ac',
          price: 1200000,
          description: 'Kamar kost dengan AC, ukuran 3x4 meter',
          images: [
            'https://picsum.photos/seed/kost2/400/300.jpg',
            'https://picsum.photos/seed/kost2_2/400/300.jpg'
          ],
          facilities: ['Kasur', 'Lemari', 'Meja Belajar', 'AC', 'TV'],
          location: 'Jl. Tegalgondo No. 123, Malang',
          rating: 4.5,
          available: true,
        ),
        KostModel(
          id: '3',
          name: 'Kamar Deluxe',
          type: 'deluxe',
          price: 1800000,
          description: 'Kamar kost deluxe dengan kamar mandi dalam',
          images: [
            'https://picsum.photos/seed/kost3/400/300.jpg',
            'https://picsum.photos/seed/kost3_2/400/300.jpg'
          ],
          facilities: [
            'Kasur',
            'Lemari',
            'Meja Belajar',
            'AC',
            'TV',
            'Kamar Mandi Dalam'
          ],
          location: 'Jl. Tegalgondo No. 123, Malang',
          rating: 4.8,
          available: true,
        ),
      ];

      final mockServices = [
        ServiceModel(
            id: '1',
            name: 'Laundry Express',
            description: 'Layanan laundry kilat',
            price: 8000,
            unit: 'kg',
            icon: 'laundry',
            category: 'laundry'),
        ServiceModel(
            id: '2',
            name: 'Buang Sampah Harian',
            description: 'Penjemputan sampah',
            price: 50000,
            unit: 'bulan',
            icon: 'trash',
            category: 'cleaning'),
        ServiceModel(
            id: '3',
            name: 'Bersih - Bersih Kamar',
            description: 'Pembersihan kamar',
            price: 75000,
            unit: 'bulan',
            icon: 'cleaning',
            category: 'cleaning'),
      ];

      return {'kosts': mockKosts, 'services': mockServices};
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}
