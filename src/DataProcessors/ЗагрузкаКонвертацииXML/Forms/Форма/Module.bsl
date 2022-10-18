#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("парКонвертация") И ЗначениеЗаполнено(Параметры.парКонвертация) Тогда
		Объект.Конвертация = Параметры.ПарКонвертация;
	КонецЕсли;
	КонвертацияПриИзмененииНаСервере();
	Если НЕ ЗначениеЗаполнено(Объект.Конфигурация) Тогда
		СоздатьНовуюКонфигурацию = Истина;
	КонецЕсли;
	//Если НЕ ЗначениеЗаполнено(Объект.КонфигурацияКорреспондент) Тогда
	//	СоздатьНовуюКонфигурациюКорреспондент = Истина;
	//КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УстановитьВидимость();
КонецПроцедуры
#КонецОбласти
#Область ОбработчикиСобытийЭлементовШапкиФормы
&НаКлиенте
Процедура ИмяФайлаПравилНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Файл данных (*.xml)'") + "|*.xml" );
	НастройкиДиалога.Вставить("Заголовок", НСтр("ru='Выберите файл с правилами конвертации'"));

	
	Оповещение = Новый ОписаниеОповещения("ЗавершениеВыбораФайлаПравил", ЭтотОбъект);
	МодульОбменДаннымиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбменДаннымиКлиент");
	МодульОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, НастройкиДиалога, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура СпособЗагрузкиКонвертацииПриИзменении(Элемент)
	Если СпособЗагрузкиКонвертации = 0 Тогда
		Объект.Конвертация = Неопределено;
	КонецЕсли;
	УстановитьВидимость();
КонецПроцедуры

&НаКлиенте
Процедура КонвертацияПриИзменении(Элемент)
	КонвертацияПриИзмененииНаСервере();
	УстановитьВидимость();
КонецПроцедуры

&НаКлиенте
Процедура ФлагиПриИзменении(Элемент)
	УстановитьВидимость()
КонецПроцедуры

#КонецОбласти
#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура ВыполнитьЗагрузку(Команда)
	Если НЕ ЗначениеЗаполнено(Объект.ИмяФайлаПравил) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Не выбран файл с правилами конвертации'"));
		Возврат;
	КонецЕсли;
	Если СпособЗагрузкиКонвертации > 0 И НЕ ЗначениеЗаполнено(Объект.Конвертация) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Не выбрана конвертация для загрузки правил'"));
		Возврат;
	КонецЕсли; 
	Если НЕ ЗначениеЗаполнено(Объект.Конфигурация) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Не выбрана конфигурация источник'"));
		Возврат;
	КонецЕсли;
	//Если НЕ КонфигурацииСовпадают И НЕ ЗначениеЗаполнено(Объект.КонфигурацияКорреспондент) Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Не выбрана конфигурация получатель'"));
	//	Возврат;
	//КонецЕсли;

	Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.Ожидание;
	ИзменитьДоступностьЭлементовФормы(Ложь);
	ПодключитьОбработчикОжидания("ЗапускОбработки", 5, Истина);
КонецПроцедуры
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
&НаСервере
Процедура КонвертацияПриИзмененииНаСервере()
	Если НЕ ЗначениеЗаполнено(Объект.Конвертация) Тогда
		Объект.Конфигурация = Справочники.Конфигурации.ПустаяСсылка();
		//Объект.КонфигурацияКорреспондент = Справочники.Релизы.ПустаяСсылка();
		СпособЗагрузкиКонвертации = 0;
	КонецЕсли;
	
	ДанныеКонвертации = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Объект.Конвертация, "Источник");
	Объект.Конфигурация = ДанныеКонвертации.Источник;
	//ДанныеКонвертации = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Объект.Конвертация, "Конфигурация, КонфигурацияКорреспондент");
	//Объект.Конфигурация = ДанныеКонвертации.Конфигурация;
	//Объект.КонфигурацияКорреспондент = ДанныеКонвертации.КонфигурацияКорреспондент;
	
	Если СпособЗагрузкиКонвертации = 0 Тогда
		СпособЗагрузкиКонвертации = 1;
	КонецЕсли;
	//Если Объект.Конфигурация = Объект.КонфигурацияКорреспондент И ЗначениеЗаполнено(Объект.Конфигурация) Тогда
	//	КонфигурацииСовпадают = Истина;
	//КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗавершениеВыбораФайлаПравил(Знач РезультатПомещенияФайлов, Знач ДополнительныеПараметры) Экспорт
	АдресФайлаПравил = РезультатПомещенияФайлов.Хранение;
	ТекстОшибки           = РезультатПомещенияФайлов.ОписаниеОшибки;
	
	Объект.ИмяФайлаПравил = РезультатПомещенияФайлов.Имя;
	Если ПустаяСтрока(ТекстОшибки) И ПустаяСтрока(АдресФайлаПравил) Тогда
		ТекстОшибки = НСтр("ru = 'Ошибка передачи файла с правилами конвертации на сервер'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки, , "Объект.ИмяФайлаПравил");
	Иначе
		ПолучитьДанныеКонвертацииИзФайла();
		УстановитьВидимость();
	КонецЕсли;
	ОбновитьОтображениеДанных();

КонецПроцедуры

&НаКлиенте
Процедура УстановитьВидимость()
	//Элементы.ГруппаКонфигурацияКорреспондент.Видимость = НЕ КонфигурацииСовпадают;
	Элементы.Конвертация.АвтоОтметкаНезаполненного = (СпособЗагрузкиКонвертации > 0);
	Элементы.Конвертация.Видимость = (СпособЗагрузкиКонвертации > 0);
	Элементы.ИмяКонвертацииДляЗагрузки.Видимость = (СпособЗагрузкиКонвертации = 0);
	Элементы.Конфигурация.АвтоОтметкаНезаполненного = Истина;
	//Элементы.КонфигурацияКорреспондент.АвтоОтметкаНезаполненного = НЕ КонфигурацииСовпадают;
	//Элементы.КонфигурацияКорреспондент.Видимость = НЕ КонфигурацииСовпадают;
КонецПроцедуры

&НаСервере
Процедура ПолучитьДанныеКонвертацииИзФайла()
	ИдентификаторЗадания = Неопределено;
	ДлительнаяОперация = Ложь;
	АдресХранилищаРезультата = Неопределено;
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайлаПравил);
	ИмяФайлаПравил = ПолучитьИмяВременногоФайла("xml");
	ДвоичныеДанные.Записать(ИмяФайлаПравил);
	СтруктураПараметров = Новый Структура("ИмяФайлаПравил", ИмяФайлаПравил);
	Попытка
		ПараметрыФоновогоЗадания = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
		ПараметрыФоновогоЗадания.НаименованиеФоновогоЗадания = НСтр("ru = 'Получение данных из правил конвертации XML'");
		ПараметрыФоновогоЗадания.ЗапуститьВФоне = Истина;
		Результат = ДлительныеОперации.ВыполнитьВФоне("Обработки.ЗагрузкаКонвертацииXML.ПолучитьДанныеКонвертацииИзФайла",
			СтруктураПараметров, ПараметрыФоновогоЗадания);
		АдресХранилищаРезультата = Результат.АдресРезультата;
		Если Результат.Статус = "Выполнено" Тогда
			РезультатЗагрузки = ПолучитьИзВременногоХранилища(АдресХранилищаРезультата);
			Если РезультатЗагрузки.Успешно Тогда
				ЗаполнитьДанныеФормыПоДаннымФайлаПравил(РезультатЗагрузки);
			Иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Ошибка при получении данных из правил конвертации XML'"));
			КонецЕсли;
			Попытка
				УдалитьФайлы(ИмяФайлаПравил);
			Исключение
				ИмяФайлаПравил = "";
			КонецПопытки;
		Иначе
			ДлительнаяОперация = Истина;
			ИдентификаторЗадания = Результат.ИдентификаторЗадания;
		КонецЕсли;
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Ошибка при получении данных из правил конвертации XML'") + Символы.ПС + ОписаниеОшибки());
		Возврат;
	КонецПопытки 

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДанныеФормыПоДаннымФайлаПравил(РезультатЗагрузки)
	Если РезультатЗагрузки.Свойство("Конфигурация") Тогда
		Объект.Конфигурация = РезультатЗагрузки.Конфигурация;
		СоздатьНовуюКонфигурацию = Ложь;
	ИначеЕсли РезультатЗагрузки.Свойство("Источник") Тогда
		ИмяКонфигурацииДляЗагрузки = РезультатЗагрузки.Источник;
		СоздатьНовуюКонфигурацию = Истина;
	КонецЕсли;
	//Если РезультатЗагрузки.Свойство("КонфигурацияКорреспондент") Тогда
	//	Объект.КонфигурацияКорреспондент = РезультатЗагрузки.КонфигурацияКорреспондент;
	//	СоздатьНовуюКонфигурациюКорреспондент = Ложь;
	//ИначеЕсли РезультатЗагрузки.Свойство("Приемник") Тогда
	//	ИмяКонфигурацииКорреспондентДляЗагрузки = РезультатЗагрузки.Приемник;
	//	СоздатьНовуюКонфигурациюКорреспондент = Истина; //?
	//КонецЕсли;
	Если РезультатЗагрузки.Свойство("Конвертация") Тогда
		Объект.Конвертация = РезультатЗагрузки.Конвертация;
		СпособЗагрузкиКонвертации = 1;
	ИначеЕсли РезультатЗагрузки.Свойство("Наименование") Тогда
		ИмяКонвертацииДляЗагрузки = РезультатЗагрузки.Наименование;
		СпособЗагрузкиКонвертации = 0;
	КонецЕсли;
	//Если Объект.Конфигурация = Объект.КонфигурацияКорреспондент И ЗначениеЗаполнено(Объект.Конфигурация) Тогда
	//	КонфигурацииСовпадают = Истина;
	//ИначеЕсли ЗначениеЗаполнено(ИмяКонфигурацииДляЗагрузки) 
	//	И СокрЛП(ИмяКонфигурацииДляЗагрузки) = СокрЛП(ИмяКонфигурацииКорреспондентДляЗагрузки) Тогда
	//	КонфигурацииСовпадают = Истина;
	//Иначе
	//	КонфигурацииСовпадают = Ложь;
	//КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОкончаниеЗагрузкиКонвертации()
	РезультатЗагрузки = ПолучитьИзВременногоХранилища(АдресХранилищаРезультата);
	Если РезультатЗагрузки.ЗагрузкаШапки Тогда
		Если РезультатЗагрузки.Успешно Тогда
			ЗаполнитьДанныеФормыПоДаннымФайлаПравил(РезультатЗагрузки);
		Иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Ошибка чтения правил конфигурации'"));
			Объект.Конфигурация = Неопределено;
			//Объект.КонфигурацияКорреспондент = Неопределено;
			Объект.Конвертация = Неопределено;
			СпособЗагрузкиКонвертации = 0;
		КонецЕсли;
	Иначе
		Если РезультатЗагрузки.Успешно Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Загрузка правил конвертации выполнена успешно'"));
		Иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Загрузка правил конвертации не выполнена'"));
		КонецЕсли;
	КонецЕсли;
	Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.Основная;
	УстановитьВидимость();
	ИзменитьДоступностьЭлементовФормы(Истина);
КонецПроцедуры


&НаКлиенте
Процедура ОбработчикОжиданияДлительнойОперации()
	Если НЕ ДлительнаяОперация Тогда
		Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.Основная;
		ИзменитьДоступностьЭлементовФормы(Истина);
		Возврат;
	КонецЕсли;
	Если ДлительнаяОперацияВыполнена() Тогда
		ДлительнаяОперация = Ложь;
		ПодключитьОбработчикОжидания("ОкончаниеЗагрузкиКонвертации", 1, Истина);
	Иначе
		ПодключитьОбработчикОжидания("ОбработчикОжиданияДлительнойОперации", 5, Истина);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ДлительнаяОперацияВыполнена()
	Если ИдентификаторЗадания = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	Возврат ДлительныеОперации.ЗаданиеВыполнено(ИдентификаторЗадания);
КонецФункции

&НаКлиенте
Процедура ИзменитьДоступностьЭлементовФормы(ФлагДоступность)
	Элементы.ФормаВыполнитьЗагрузку.Доступность = ФлагДоступность;
КонецПроцедуры

&НаКлиенте
Процедура ЗапускОбработки()
	ВыполнитьЗагрузкуСервер();
	ПодключитьОбработчикОжидания("ОбработчикОжиданияДлительнойОперации", 5, Истина);
КонецПроцедуры

&НаСервере
Процедура ВыполнитьЗагрузкуСервер()
	ИдентификаторЗадания = Неопределено;
	ДлительнаяОперация = Ложь;
	АдресХранилищаРезультата = Неопределено;
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайлаПравил);
	ИмяФайлаПравил = ПолучитьИмяВременногоФайла("xml");
	ДвоичныеДанные.Записать(ИмяФайлаПравил);
	СтруктураПараметров = Новый Структура("СпособЗагрузкиКонвертации, ИмяФайлаПравил",
						СпособЗагрузкиКонвертации, ИмяФайлаПравил);
	СтруктураПараметров.Вставить("Конфигурация", Объект.Конфигурация);
	//СтруктураПараметров.Вставить("КонфигурацияКорреспондент", Объект.КонфигурацияКорреспондент);
	СтруктураПараметров.Вставить("КонвертацияСсылка", Объект.Конвертация);
	//СтруктураПараметров.Вставить("КонфигурацииСовпадают", КонфигурацииСовпадают);
	СтруктураПараметров.Вставить("ИмяКонвертацииДляЗагрузки", ИмяКонвертацииДляЗагрузки);

	Попытка
		ПараметрыФоновогоЗадания = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
		ПараметрыФоновогоЗадания.НаименованиеФоновогоЗадания = НСтр("ru = 'Загрузка правил конвертации XML'");
		ПараметрыФоновогоЗадания.ЗапуститьВФоне = Истина;
		Результат = ДлительныеОперации.ВыполнитьВФоне("Обработки.ЗагрузкаКонвертацииXML.ВыполнитьЗагрузкуПравил",
			СтруктураПараметров, ПараметрыФоновогоЗадания);
		АдресХранилищаРезультата = Результат.АдресРезультата;
		Если Результат.Статус = "Выполнено" Тогда
			РезультатЗагрузки = ПолучитьИзВременногоХранилища(АдресХранилищаРезультата);
			Если РезультатЗагрузки.Успешно Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Загрузка правил конвертации выполнена успешно'"));
			Иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Загрузка правил конвертации не выполнена'"));
			КонецЕсли;
			Попытка
				УдалитьФайлы(ИмяФайлаПравил);
			Исключение
				ИмяФайлаПравил = "";
			КонецПопытки;
		Иначе
			ДлительнаяОперация = Истина;
			ИдентификаторЗадания = Результат.ИдентификаторЗадания;
		КонецЕсли;
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'При загрузке правил конвертации произошла ошибка'") + Символы.ПС + ОписаниеОшибки());
		Возврат;
	КонецПопытки
КонецПроцедуры


#КонецОбласти
