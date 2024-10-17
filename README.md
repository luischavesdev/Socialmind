# <img width="361" alt="logo_2x" src="https://github.com/user-attachments/assets/1f13ad1f-d913-451b-b837-ec49a4a20074">
<p align="justify">
 Socialmind is a social take on the classic Mastermind code breaking game, introducing social features, like location-based play, and simultaneous 1v1 code guessing by the two competing 
 players. Some features include:
</p>

- Customizable player profile
- Real-time geo tracking
- MQTT based multiplayer

## Build/Run Instructions
<p align="justify">
 If you want to quickly test the app, the apk can be installed on an android phone/emulator, but you'll always have to setup, configure, and run an MQTT broker locally. In case you do not 
 want to rebuild the app, be sure to setup the broker according to the <code>CustomMQTTManager</code> class settings present on the <code>mqtt_manager.dart</code> file, and you should be able to get several
 emulator instances working on localhost. To run a multiplayer match on different devices you'll have to rebuild the app taking into account a private IP of some sorts. As for the broker, 
 it's up to you, but our testing was done with RabbitMQ for example.
</p>
Also, suffice to say, Firebase functionality is now down, so you won't actually be able to see if there are other players in your proximities.

## Screenshots
<img src="https://github.com/user-attachments/assets/2a2a3db8-f9e8-4048-bde6-b0cd93cf4623" width="200">
<img src="https://github.com/user-attachments/assets/bcab70ff-95c4-47e2-8959-9fceb8d9b2f8" width="200">
