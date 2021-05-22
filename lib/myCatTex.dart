import 'package:alaket_ios/creatMyTex.dart';
import 'package:alaket_ios/my_texnika.dart';
import 'package:alaket_ios/requesters_tab_winget.dart';
import 'package:flutter/material.dart';

class MyCatTexnik extends StatefulWidget {
  MyCatTexnik({Key key}) : super(key: key);

  @override
  _MyCatTexnikState createState() => _MyCatTexnikState();
}

class _MyCatTexnikState extends State<MyCatTexnik> {
  final name = [
    'Автобус',
    'Автобус (микро)',
    'Автобетононасос',
    'Автобетононасос с самозагрузкой',
    'Автобетоносместитель',
    'Автовоз',
    'Автовышка',
    'Автодом',
    'Автокран',
    'Автоцистерна',
    'Ассенизатор',
    'Асфальтоукладчик',
    'Бензовоз',
    'Бульдозер',
    'Бортовой грузовик',
    'Буровое оборудование',
    'Вездеход',
    'Водовоз',
    'Газель бортовой',
    'Газозаправщик',
    'Генератор',
    'Гидробур',
    'Грейдер',
    'Гусеничный кран',
    'Длинномер',
    'Дробилка',
    'Каток',
    'Компрессор',
    'Контейнеровоз',
    'Кран автомобильный',
    'Кран башенный',
    'Кран гусенечный',
    'Кунг',
    'Коммунальная спецтехника',
    'Манипулятор',
    'Манипулятор-вездеход',
    'Молоковоз',
    'Мусоровоз',
    'Нефтевоз',
    'Погрузчик',
    'Погрузчик вилочный',
    'Погрузчик ковшовый',
    'Погрузчик ленточный',
    'Погручзик платформенный',
    'Погрузчик роторный',
    'Погрузчик шнековый',
    'Погрузчик-копновоз',
    'Погрузчик-манипулятор',
    'Погрузчик непрерывного действия',
    'Прицепы, полуприцепы',
    'Прицепы дачи',
    'Рефрижератор',
    'Самосвал',
    'Сварочное оборудование',
    'Сельхозтехника',
    'Сеновоз',
    'Скотовоз',
    'Снегоуборщик',
    'Топливозаправщик',
    'Трактор',
    'Трал',
    'Траншеекопатель',
    'Тягач',
    'Фреза',
    'Фура',
    'Фургон',
    'Цементовоз',
    'Штабелер',
    'Щётка дорожная',
    'Эвакуатор',
    'Эвакуатор грузовой',
    'Эвакуатор',
    'Экскаватор мини',
    'Экскаватор-погрузчик',
    'Эвакуторная платформа',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      itemCount: name.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CreateMyTex(
                      myCatTex: name[index],
                    )));
          },
          child: ListTile(
            title: Text(name[index]),
          ),
        );
      },
    ));
  }
}
