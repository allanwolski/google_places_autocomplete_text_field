import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/src/model/place_details.dart';
import 'package:google_places_autocomplete_text_field/src/model/prediction.dart';

/// {@template google_places_api}
/// Interface for Google Places API.
/// {@endtemplate}
class GooglePlacesApi {
  /// {@macro google_places_api}
  GooglePlacesApi() : _dio = Dio();

  /// The [Dio] instance used to make HTTP requests.
  final Dio _dio;

  /// The API URL for the Google Places API.
  final _apiUrl = 'https://places.googleapis.com/v1/places';

  /// Fetches suggestions for the given [input] with the provided
  /// [googleAPIKey].
  Future<PlacesAutocompleteResponse?> getSuggestionsForInput({
    required String input,
    required String googleAPIKey,
    List<String> countries = const [],
    String? sessionToken,
    String proxyUrl = '',
    String? languageCode,
  }) async {
    final prefix = proxyUrl;

    String url = "$prefix$_apiUrl:autocomplete";

    Map<String, dynamic> requestBody = {
      "input": input,
    };

    if (countries.isNotEmpty) {
      requestBody["includedRegionCodes"] = countries;
      requestBody["languageCode"] = languageCode;
    }
    if (sessionToken != null) {
      requestBody["sessionToken"] = sessionToken;
    }
    Options options = Options(
      headers: {
        "X-Goog-Api-Key": googleAPIKey,
        "X-Goog-FieldMask": "*",
      },
    );

    try {
      final response =
          await _dio.post(url, options: options, data: jsonEncode(requestBody));
      final subscriptionResponse =
          PlacesAutocompleteResponse.fromJson(response.data);
      return subscriptionResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(
            'GooglePlacesApi.getSuggestionsForInput: DioException [${e.type}]: ${e.message}');
        debugPrint('Response data: ${e.response?.data}');
      } else {
        debugPrint(
            'GooglePlacesApi.getSuggestionsForInput: DioException [${e.type}]: ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint('GooglePlacesApi.getSuggestionsForInput: ${e.toString()}');
      return null;
    }
  }

  /// Fetches the place details for the given [prediction] with the provided
  /// [googleAPIKey].
  Future<PlaceDetails?> fetchCoordinatesForPrediction({
    required Prediction prediction,
    required String googleAPIKey,
    String proxyUrl = '',
    String? sessionToken,
  }) async {
    try {
      final prefix = proxyUrl;

      String url =
          "$prefix$_apiUrl/${prediction.placeId}?fields=*&key=$googleAPIKey";
      if (sessionToken != null) {
        url += "&sessionToken=$sessionToken";
      }
      final response = await _dio.get(url);

      final placeDetails = PlaceDetails.fromJson(response.data);

      return placeDetails;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(
            'GooglePlacesApi.fetchCoordinatesForPrediction: DioException [${e.type}]: ${e.message}');
        debugPrint('Response data: ${e.response?.data}');
      } else {
        debugPrint(
            'GooglePlacesApi.fetchCoordinatesForPrediction: DioException [${e.type}]: ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint(
          'GooglePlacesApi.fetchCoordinatesForPrediction: ${e.toString()}');
      return null;
    }
  }
}
