![logo_parkme](https://github.com/morsimantov/Park-Me/assets/92635551/ab4ac973-a207-432e-af1a-22d821800378)
1. [About](#About)
2. [Dependencies](#Dependencies)
3. [Overview](#Overview)
   _[Find a Spot Now](#FindaSpotNow) 

## About

**ParkMe is an app we created as a final project in our B.Sc of Compter Science in BIU. Its goal is to help you easily find an available parking spot in a parking lot.**

The app was designed in Flutter using Django server side integrated with Firebase cloud database (Firestore).

We thought about the parking problem in Tel Aviv, that almost every person encounters. We wanted to find a solution while answering each individual’s needs – whether it's personal preferences such as price and accessibility, or the need to plan a drive ahead due to the frequent changes in the occupancy of parking lots.

The main innovation aspect of the project:

**planning a drive ahead – meaning searching a parking lot a certain time ahead, and predicting if it’s going to be available**, in order to plan your drive in advance without having to worry about a parking lot at the last minute. 

We collected data over the span of nearly 6 months and analyzed it. We utilized advanced machine learning algorithms and trained different models in order to find the optimal one, with emphasis on high accuracy. There are also a lot of parking lots without information about their occupancy, and our model strives to predict about them as well.

We also designed a searching mechanism that considers different preferences of the user, such as availability, walking distance, price and more, that suggests the user parking lots accordingly.


## Dependencies

* Clone the repository
* Server side - download the server side code in the link: https://github.com/ShaiFisher1/Parkme-Django-Firebase-Server and follow installation instruction.
* In order to activate the server side, make sure your'e inside the "parkmefire" folder, within this path use the following command in the terminal:

```
python manage.py runserver
```

## Overview

Welcome to ParkMe!

First, you need to sign up with your google account:

![image](https://github.com/morsimantov/Park-Me/assets/92635551/8bdf77b5-c088-48d0-91bd-c3f20c44afdd)

After signing up the app will remember you in any future visit (unless you logout).

The main menu of the app:

![image](https://github.com/morsimantov/Park-Me/assets/92635551/db3c7c10-03e0-403a-b5b1-8ffbcb6fb686)

Now we'll guide you through the different categories.

### Find a Spot Now

If you want to find a parking spot available near you at this moment.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/e0bd44f3-e9bf-46f4-923b-99696abe0d94)

You can write an address you need to go to, in order to find a parking place in the area. There is a places autocomplete.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/638ade50-fb2c-4fb4-94bb-d1f489fe4d7a)

You can move the map as you'd like and pin a location you want to search parking near it. There is a button that guides you back to your location ("Current Location" on the left).

You can also use ordering and filtering options by the right button in the search box.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/51da3b19-5e24-4485-be33-e49b83998610)


### Plan a Drive

### Favorites (Saved Lots)

You can save your preffered parking lots (by marking the star on the right) and they'll be saved for you in the Favorites category.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/f1ee9d43-c4d0-41b9-877b-ffed44dd6a91)


### Parking Lots Nearby

You can checkout the parking lots that are currently near you. Near the the available lots there's a green spot (red spot for full and orange for crowded).

Note: our app works with live location, therefore requires that you consent to location sharing in your device.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/b38edf49-bd25-4709-bc67-56af3b3037f8)
