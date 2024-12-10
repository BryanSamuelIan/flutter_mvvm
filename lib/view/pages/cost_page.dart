part of 'pages.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  dynamic selectedProvince;
  dynamic selectedCity;
  HomeViewmodel homeViewmodel = HomeViewmodel();

  @override
  void initState() {
    // TODO: implement initState
    homeViewmodel.getProvinceList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Calculate cost"),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider<HomeViewmodel>(
        create: (context) => homeViewmodel,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Flexible(
                  flex: 1,
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // dropdown list province
                          Consumer<HomeViewmodel>(builder: (context, value, _) {
                            switch (value.provinceList.status) {
                              case Status.loading:
                                return Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                );

                              case Status.error:
                                return Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      value.provinceList.message.toString()),
                                );

                              case Status.completed:
                                return DropdownButton(
                                    isExpanded: true,
                                    value: selectedProvince,
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconSize: 30,
                                    elevation: 2,
                                    hint: Text("Please select the province..."),
                                    style: TextStyle(color: Colors.black),
                                    items: value.provinceList.data!
                                        .map<DropdownMenuItem<Province>>(
                                            (Province value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(value.province.toString()),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedProvince = newValue;
                                        selectedCity = null;
                                        homeViewmodel.getCityList(selectedProvince.provinceId);
                                      });
                                    });
                              default:
                            }
                            return Container();
                          }),

                          //dropdown list city
                          Consumer<HomeViewmodel>(builder: (context, value, _) {
                            switch (value.cityList.status) {
                              case Status.loading:
                                return Align(
                                  alignment: Alignment.center,
                                  child: Text("Please choose the province first!"),
                                );
                              case Status.error:
                                return Align(
                                  alignment: Alignment.center,
                                  child:
                                      Text(value.cityList.message.toString()),
                                );
                              case Status.completed:
                                return DropdownButton(
                                    isExpanded: true,
                                    value: selectedCity,
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconSize: 30,
                                    elevation: 2,
                                    hint: Text('Pilih city'),
                                    style: TextStyle(color: Colors.black),
                                    items: value.cityList.data!
                                        .map<DropdownMenuItem<City>>(
                                            (City value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(value.cityName.toString()),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedCity = newValue;
                                      });
                                    });
                              default:
                            }
                            return Container();
                          }),
                          //dropdown list city
                        ],
                      ),
                    ),
                  )),
              Flexible(
                  flex: 2,
                  child: Container(
                    color: Colors.amber,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}