![logo_parkme](https://github.com/morsimantov/Park-Me/assets/92635551/ab4ac973-a207-432e-af1a-22d821800378)  Park Me

1. [About](#About)
2. [Dependencies](#Dependencies)
3. [Overview](#Overview)

## About

### ParkMe is an app we created as a final project in our B.Sc of Compter Science. 

Its goal is to help you find an available parking spot in a parking lot.

The app was designed in Flutter using Django server side integrated with Firebase cloud database (Firestore).

We thought about the parking problem in Tel Aviv, that almost every person in the city and outside it encounters. We wanted to find a solution that would alleviate the problem while answering each individual’s needs – whether it's personal preferences such as price and accessibility, or the need to plan a drive ahead due to the frequent changes in the occupancy of parking lots.

The main innovation aspect of the project is **planning a drive ahead – meaning searching a parking lot a certain time ahead, and predicting if it’s going to be available**, in order to plan your drive in advance without having to worry about a parking lot at the last minute. 

We collected data over the span of nearly 6 months and analyzed it. We utilized advanced machine learning algorithms and trained different models in order to find the optimal one, with emphasis on high accuracy. There are also a lot of parking lots without information about their occupancy, and our model strives to predict about them as well.

We also designed a searching mechanism that considers different preferences of the user, such as availability, walking distance, price and more, that suggests the user parking lots accordingly.


## Dependencies

* Clone the repository
* Server side - download the server side code in the link: https://github.com/ShaiFisher1/Parkme-Django-Firebase-Server and follow installation instruction.
* In order to activate the server side, make sure your'e inside the "parkmefire" folder, within this path use the following command in the terminal:

'''
python manage.py runserver
'''
  

## Overview
