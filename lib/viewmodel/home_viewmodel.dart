import 'package:flutter/material.dart';
import 'package:flutter_mvvm/data/response/api_response.dart';
import 'package:flutter_mvvm/model/city.dart';
import 'package:flutter_mvvm/model/model.dart';
import 'package:flutter_mvvm/repository/home_repository.dart';

class HomeViewmodel with ChangeNotifier {
  final _homeRepo = HomeRepository();
  ApiResponse<List<Province>> provinceList = ApiResponse.loading();
  ApiResponse<List<City>> cityList = ApiResponse.loading();

  setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  setCityList(ApiResponse<List<City>> response) {
    cityList = response;
    notifyListeners();
  }

  Future<void> getProvinceList() async {
    setProvinceList(ApiResponse.loading());
    _homeRepo.fetchProvinceList().then((value) {
      setProvinceList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setProvinceList(ApiResponse.error(error.toString()));
    });
  }

  Future<void> getCityList(var provId) async {
    setCityList(ApiResponse.loading());
    _homeRepo.fetchCityList(provId).then((value) {
      setCityList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setCityList(ApiResponse.error(error.toString()));
    });
  }

  
}
