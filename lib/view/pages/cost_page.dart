part of 'pages.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  dynamic selectedOriginProvince;
  dynamic selectedOriginCity;
  dynamic selectedDestinationProvince;
  dynamic selectedDestinationCity;
  String selectedCourier = 'jne';
  final TextEditingController _weightController = TextEditingController();

  HomeViewmodel homeViewmodel = HomeViewmodel();

  @override
  void initState() {
    super.initState();
    homeViewmodel.getProvinceList();
    // Reset costResult to not loading when the page is loaded
    homeViewmodel.resetCostResult();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.orange,
      title: Text("Calculate Cost"),
      centerTitle: true,
    ),
    body: ChangeNotifierProvider<HomeViewmodel>(
      create: (context) => homeViewmodel,
      child: Consumer<HomeViewmodel>(
        builder: (context, homeViewmodel, child) {
          return Stack(
            children: [
              SingleChildScrollView( // Wrap the content with SingleChildScrollView
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Origin Province and City Dropdowns
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Origin",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: _buildProvinceDropdown(
                            homeViewmodel,
                            'Origin Province',
                            (String? value) {
                              setState(() {
                                selectedOriginProvince = value;
                                selectedOriginCity =
                                    null; // Reset origin city when province is changed
                              });
                              // Immediately reset and fetch origin cities
                              homeViewmodel.getOriginCityList(value!);
                            },
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: _buildCityDropdown(
                            homeViewmodel.originCityList,
                            'Origin City',
                            (String? value) {
                              if (selectedOriginProvince == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please select an origin province first')),
                                );
                              } else {
                                setState(() {
                                  selectedOriginCity = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),

                    // Destination Province and City Dropdowns
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Destination",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: _buildProvinceDropdown(
                            homeViewmodel,
                            'Destination Province',
                            (String? value) {
                              setState(() {
                                selectedDestinationProvince = value;
                                selectedDestinationCity =
                                    null; // Reset destination city when province is changed
                              });
                              // Immediately reset and fetch destination cities
                              homeViewmodel.getDestinationCityList(value!);
                            },
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: _buildCityDropdown(
                            homeViewmodel.destinationCityList,
                            'Destination City',
                            (String? value) {
                              if (selectedDestinationProvince == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please select a destination province first')),
                                );
                              } else {
                                setState(() {
                                  selectedDestinationCity = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),

                    // Courier and Weight Dropdown
                    Row(
                      children: [
                        // Courier Dropdown with smaller space
                        Expanded(
                          flex:
                              2, // This will take up a smaller portion of the row
                          child: DropdownButton<String>(
                            value: selectedCourier,
                            items: ['jne', 'pos', 'tiki'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCourier = newValue!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8.0),
                        // Weight Input with larger space
                        Expanded(
                          flex: 5, // This will take up more space in the row
                          child: TextField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: 'Berat (gr)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    // Calculate Button
                    ElevatedButton(
                      onPressed: () {
                        if (selectedOriginCity != null &&
                            selectedDestinationCity != null &&
                            _weightController.text.isNotEmpty) {
                          homeViewmodel.calculateCost(
                            origin: selectedOriginCity!,
                            destination: selectedDestinationCity!,
                            weight: int.parse(_weightController.text),
                            courier: selectedCourier,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please fill in all fields')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text('Hitung Estimasi Harga'),
                    ),
                    SizedBox(height: 16.0),

                    // Display Cost Results, only if loading is done
                    if (homeViewmodel.costResult.status != Status.loading)
                      _buildCostResult(homeViewmodel),
                  ],
                ),
              ),
              // Loading Indicator Overlay
              if (homeViewmodel.costResult.status == Status.loading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}


  // Build City Dropdown
  Widget _buildCityDropdown(ApiResponse<List<City>> cityList, String label,
      ValueChanged<String?> onChanged) {
    return Consumer<HomeViewmodel>(
      builder: (context, value, child) {
        switch (cityList.status) {
          case Status.loading:
            return Center(child: CircularProgressIndicator());
          case Status.error:
            return Center(
                child: Text(cityList.message ?? 'Error fetching cities'));
          case Status.completed:
            return DropdownButton<String>(
              isExpanded: true,
              value: label == 'Origin City'
                  ? selectedOriginCity
                  : selectedDestinationCity,
              hint: Text("Select City"),
              items: cityList.data!.map<DropdownMenuItem<String>>((City city) {
                return DropdownMenuItem<String>(
                  value: city.cityId,
                  child: Text(city.cityName ?? 'Unknown City'),
                );
              }).toList(),
              onChanged: onChanged,
            );
          default:
            return Container();
        }
      },
    );
  }

  Widget _buildCostResult(HomeViewmodel homeViewModel) {
    return Consumer<HomeViewmodel>(
      builder: (context, value, child) {
        if (value.costResult.status == Status.loading &&
            value.costResult.data == null) {
          return Center(child: Text('No data')); // Show 'No data' initially
        }

        switch (value.costResult.status) {
          case Status.loading:
            return Center(child: CircularProgressIndicator());
          case Status.error:
            return Center(child: Text(value.costResult.message.toString()));
          case Status.completed:
            // Access the cost data
            if (value.costResult.data?.costs != null &&
                value.costResult.data!.costs!.isNotEmpty) {
              return SingleChildScrollView(
                // Wrap the result list in SingleChildScrollView
                child: Column(
                  children: value.costResult.data!.costs!.map((costs) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          costs.service ?? 'No Service',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(costs.description ?? 'No Description'),
                            if (costs.cost != null && costs.cost!.isNotEmpty)
                              Text(
                                'Rp${costs.cost!.first.value}, Estimasi sampai: ${costs.cost!.first.etd}',
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              return Center(child: Text('No cost data available.'));
            }
          default:
            return Container();
        }
      },
    );
  }
}
