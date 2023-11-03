![logo_parkme](https://github.com/morsimantov/Park-Me/assets/92635551/ab4ac973-a207-432e-af1a-22d821800378)
1. [About](#About)
2. [Dependencies](#Dependencies)
3. [Overview](#Overview)
   
## About

**ParkMe is an app we created as a final project in our B.Sc of Compter Science in BIU. Its goal is to help you easily find an available parking spot in a parking lot.**

The app was designed in Flutter using Django server side integrated with Firebase cloud database (Firestore).

We thought about the parking problem in Tel Aviv, that almost every person encounters. We wanted to find a solution while answering each individual’s needs – whether it's personal preferences such as price and accessibility, or the need to plan a drive ahead due to the frequent changes in the occupancy of parking lots.[^1]

The main innovation aspect of the project is **planning a drive ahead – meaning searching a parking lot a certain time ahead, and predicting if it’s going to be available**, in order to plan your drive in advance without having to worry about a parking lot at the last minute. 

* We collected data over the span of nearly 6 months and analyzed it.
* We utilized advanced machine learning algorithms and trained different models in order to find the optimal one, with emphasis on high accuracy.
* There are also a lot of parking lots without information about their occupancy, and our model strives to predict about them as well.
* We also designed a searching mechanism that considers different preferences of the user, such as availability, walking distance, price and more.


## Dependencie

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

![image](https://github.com/morsimantov/Park-Me/assets/92635551/ecd8ea31-575a-4f5a-867b-633407e89732)

You can write an address you need to go to, in order to find a parking place in the area. There is a places autocomplete[^2].

<img src="https://github.com/morsimantov/Park-Me/assets/92635551/e2663fe9-cd4c-4282-a083-43f34cf52f21" height="500" />

You can move the map as you'd like and pin a location you want to search parking near it. There is a button that guides you back to your location ("Current Location" on the left).
The available and nearby lots will be presented to you and you can also order them by the buttons above, or use ordering and filtering options by the button on the top left.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/12370b83-b599-4b7f-898f-184e82767fed)

Once you tap on a parking lot, you can see different detailes about it:

![image](https://github.com/morsimantov/Park-Me/assets/92635551/134b9020-d4da-48ff-834d-15525cd092e3)

![image](https://github.com/morsimantov/Park-Me/assets/92635551/28af6420-352a-460f-9a7e-472cb7ebff28)

The Waze button will direct you to the parking lot in Waze.

### Plan a Drive

The main feature of our app is when you want to know whether a parking lot will be available a certain time ahead.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/cb5acd0b-87b2-4e96-aa6f-073db6531792)

let's say you need to drive to Tel Aviv tomorrow morning and wants to know which lot will be available near your destination at 8:30 AM.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/cb5acd0b-87b2-4e96-aa6f-073db6531792)

Now you'll be presented with the parking lots that are predicted to be available at that time, ordered by distance from your destination.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/fd5ff55f-6bcd-4d46-83a0-8c74dbb01f63)

You can also check by a specific parking lot's name, at the other tab above.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/4b47a0fb-b379-4e86-b426-342b6068e167)

![image](https://github.com/morsimantov/Park-Me/assets/92635551/e8eac99d-35fb-4bf9-a683-b9b297ef8fb1)

And now you will know whether the parking lot is going to available or not[^3]:

![image](https://github.com/morsimantov/Park-Me/assets/92635551/7c2eb2b9-7dc7-4eb1-967a-e51511a2a975)

![image](https://github.com/morsimantov/Park-Me/assets/92635551/3ed41a34-9d74-4a72-8be8-88561a811c64)

### Favorites (Saved Lots)

You can save your preffered parking lots (by marking the star icon on the right) and they'll be saved for you in the Favorites category.

![image](https://github.com/morsimantov/Park-Me/assets/92635551/eb87a0d1-de0a-4f34-8e98-87fd2e8e3783)

### Parking Lots Nearby

You can check out the parking lots that are currently near you. Near the the available lots there's a green spot (red spot for full and orange for crowded).

![image](https://github.com/morsimantov/Park-Me/assets/92635551/7c426c54-f248-4c6e-bf60-2a02c127adb2)

> [!NOTE]
> our app works with live location, therefore requires that you consent to location sharing in your device.

[^1]: Currently it covers parking lots in Tel Aviv and aimed at finding a parking space in the city.
[^2]: Using google maps autocomplete.
[^3]: With high probability.
