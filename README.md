# MultiCurrencyConversionInterface-Legacy

Steps: 
1) Run pod install from the folder with the podfile
2) Select `.xcworkspace` file and not the `.xcodeproj` file
3) Navigate to CurrencyConvertorViewController and under viewDidLoad() there is a function that is commented out `viewModel.loadOnlyOnFirstAttempt()`
4) Uncomment it then run the program once through the simulator (this is to load a default wallet into persistence)
5) Comment it and then run it again.
