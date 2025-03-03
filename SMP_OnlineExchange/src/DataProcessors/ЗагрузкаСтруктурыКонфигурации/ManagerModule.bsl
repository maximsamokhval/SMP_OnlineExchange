#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Выполняет загрузку метаданных из файлов.
// Параметры:
//   ОбщиеПеременные - Структура - Переменные, которые используются при загрузке.
//   АдресВременногоХранилища - Произвольный - Адрес, в который будет помещен результат выполнения загрузки.
Процедура ВыполнитьЗагрузкуМетаданных(ОбщиеПеременные, АдресВременногоХранилища) Экспорт
	ОбщиеПеременные.Вставить("ЗагрузитьНовую", (ОбщиеПеременные.СпособЗагрузки = 0));
	
	КоличествоОбъектов = 0;
	КоличествоСвойств = 0;
	КоличествоЗначений = 0;
	мКоличествоЭлементовДляОбновленияСтатуса = 15;
	ОбщиеПеременные.Вставить("СоответствиеУИ", Новый Соответствие);
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ОбщиеПеременные.ИмяФайлаЗагрузки);
	
	ЧтениеXML.Прочитать();
	
	Если ЧтениеXML.Имя = "Конфигурация" И ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		
	Иначе
		Сообщ = Новый СообщениеПользователю;
		Сообщ.Текст = НСтр("ru='Файл не содержит описания конфигурации'");
		Сообщ.Сообщить();
		ПоместитьВоВременноеХранилище(Ложь, АдресВременногоХранилища);
		Возврат;
	КонецЕсли;
			
	
	ЧтениеXML.Прочитать();
	
	// Загрузка конфигурации и объектов
	Пока ВозможностьЧтенияXML(ЧтениеXML) Цикл
		
		ТипXML = ПолучитьXMLТип(ЧтениеXML);
		
		Если ТипXML.ИмяТипа = "CatalogObject.Конфигурации" Тогда
			
			ПрочитатьКонфигурациюXML(ЧтениеXML, ОбщиеПеременные, Ложь);

		ИначеЕсли ТипXML.ИмяТипа = "CatalogObject.Объекты" Тогда
			
			ПрочитатьОбъектXML(ЧтениеXML, (КоличествоОбъектов - 1) % мКоличествоЭлементовДляОбновленияСтатуса = 0, ОбщиеПеременные);
			
			КоличествоОбъектов = КоличествоОбъектов + 1;
			
		Иначе
			
			ПрочитатьXML(ЧтениеXML);
			
		КонецЕсли;
		
	КонецЦикла;
	
	ЧтениеXML.Закрыть();
	// Загрузка свойств и значений
	ЧтениеXML.ОткрытьФайл(ОбщиеПеременные.ИмяФайлаЗагрузки);
	
	ЧтениеXML.Прочитать();
	ЧтениеXML.Прочитать();
	
	Пока ВозможностьЧтенияXML(ЧтениеXML) Цикл
		
		
		ТипXML = ПолучитьXMLТип(ЧтениеXML);
		Если ТипXML.ИмяТипа = "CatalogObject.Свойства" Тогда
			
			ПрочитатьСвойствоXML(ЧтениеXML, (КоличествоСвойств - 1) % мКоличествоЭлементовДляОбновленияСтатуса = 0, ОбщиеПеременные);
			
			КоличествоСвойств = КоличествоСвойств + 1;
			
		ИначеЕсли ТипXML.ИмяТипа = "CatalogObject.Значения" Тогда
			
			ПрочитатьЗначениеXML(ЧтениеXML, (КоличествоЗначений - 1) % мКоличествоЭлементовДляОбновленияСтатуса = 0, ОбщиеПеременные);
			
			КоличествоЗначений = КоличествоЗначений + 1;
			
		Иначе
			
			ПрочитатьXML(ЧтениеXML);
			
		КонецЕсли;
		
	КонецЦикла;
	
	
	Если ОбщиеПеременные.ЗагрузитьНовую <> Истина
		И НЕ ОбщиеПеременные.ДобавлятьТолькоНовые Тогда
		
		Для каждого Объект Из ОбщиеПеременные.ОбъектыКонфигурации Цикл
			
			Если Объект.Ссылка.ПометкаУдаления Тогда
				Продолжить;
			КонецЕсли;
			
			УдаленныйОбъект = Объект.Ссылка.ПолучитьОбъект();
			УдаленныйОбъект.УстановитьПометкуУдаления(Истина);
			
		КонецЦикла;
		
	КонецЕсли;
	ЧтениеXML.Закрыть();
	Попытка
		УдалитьФайлы(ОбщиеПеременные.ИмяФайлаЗагрузки);
	Исключение
	КонецПопытки;
	
	ПоместитьВоВременноеХранилище(Истина, АдресВременногоХранилища);
	
КонецПроцедуры // ВыполнитьЗагрузку()

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Формирует строковое представление типа для свойства или для описания типов.
//
// Параметры: 
//  Свойство       - Свойство, для которого необходимо получить строковое представление типа.
//  Типы           - Типы, для которых необходимо получить строковое представление.
//
// Возвращаемое значение:
//  Строка, содержащая представление типа.
//
Функция глТипыСвойстваСтрокой(Свойство) 

    Рез = "";

	Типы = Свойство.Типы;
		
	Для каждого Стр Из Типы Цикл

		ИмяТипа = СокрЛП(Стр.Тип);
		
		Если ИмяТипа = "Строка" Тогда
			
			Если Свойство.КвалификаторыСтроки_Длина = 0 Тогда
				ИмяТипа = ИмяТипа + " (Неогр)";
			Иначе
				Если Свойство.КвалификаторыСтроки_Фиксированная Тогда
					ИмяТипа = ИмяТипа + " (Ф" + Свойство.КвалификаторыСтроки_Длина + ")";
				Иначе
					ИмяТипа = ИмяТипа + " (П" + Свойство.КвалификаторыСтроки_Длина + ")";
				КонецЕсли; 
			КонецЕсли; 
			
		ИначеЕсли ИмяТипа = "Число" Тогда
			
			ИмяТипа = ИмяТипа + " (" + Свойство.КвалификаторыЧисла_Длина + "." + Свойство.КвалификаторыЧисла_Точность + ")";
			
		ИначеЕсли ИмяТипа = "Дата" Тогда
			
			ИмяТипа = Свойство.КвалификаторыДаты_Состав;
			Если ПустаяСтрока(ИмяТипа) Тогда
				
				ИмяТипа = "Дата"; // если не известно что за дата - просто пишем, что дата и все
				
			КонецЕсли;
			
		ИначеЕсли Свойство.ЭтоГруппа Тогда
			ИмяТипа = СтрЗаменить(ИмяТипа, "РегистрСведенийЗапись",		"РегистрСведенийНаборЗаписей");
			ИмяТипа = СтрЗаменить(ИмяТипа, "РегистрНакопленияЗапись",	"РегистрНакопленияНаборЗаписей");
			ИмяТипа = СтрЗаменить(ИмяТипа, "РегистрБухгалтерииЗапись",	"РегистрБухгалтерииНаборЗаписей");
			ИмяТипа = СтрЗаменить(ИмяТипа, "РегистрРасчетаЗапись",		"РегистрРасчетаНаборЗаписей");
		КонецЕсли; 
		
        Рез = Рез + ", " + ИмяТипа;
		
	КонецЦикла; 

	Возврат Прав(Рез, СтрДлина(Рез)-2);
	
КонецФункции // глТипыСвойстваСтрокой() 

Процедура ПрочитатьКонфигурациюXML(ЧтениеXML, ОбщиеПеременные, НужноМенятьНаименованиеКонфигурации = Истина)
	
	Перем Конфигурация;
	
	// Проверяем, что текущим узлом является НачалоЭлемента
	Если ЧтениеXML.ТипУзла <> ТипУзлаXML.НачалоЭлемента Тогда
		
		ВызватьИсключение НСтр("ru='Ошибка чтения XML'");
		
	КонецЕсли;
	
	// Если выполняется полная загрузка, то читаем стандартным образом
	Если ОбщиеПеременные.ЗагрузитьНовую Тогда
		
		Конфигурация = ПрочитатьXML(ЧтениеXML);
		
		Конфигурация.Записать();
		
		ОбщиеПеременные.Вставить("Конфигурация", Конфигурация.Ссылка);
		
		Возврат;
		
	КонецЕсли;
		
	// Чтение следующего узла
	ЧтениеXML.Прочитать();
	
	// Ref
	КонфигурацияСсылка = ПрочитатьXML(ЧтениеXML, Тип("СправочникСсылка.Конфигурации"));
	
	// IsFolder
	ЭтоГруппа = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
	
	// DeletionMark
	ПометкаУдаления = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
	
	// Parent
	Родитель = ПрочитатьXML(ЧтениеXML, Тип("СправочникСсылка.Конфигурации"));
	
	// Description
	Наименование = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Имя
	Имя = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Синоним
	Синоним = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Комментарий
	Комментарий = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// ДатаОбновления
	Версия = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// ДатаОбновления
	ДатаОбновления = ПрочитатьXML(ЧтениеXML, Тип("Дата"));
	
	// Приложение
	Приложение = ПрочитатьXML(ЧтениеXML, Тип("ПеречислениеСсылка.Приложения"));
	
	
	// Проверяем, что текущим узлом является КонецЭлемента
	Если ЧтениеXML.ТипУзла <> ТипУзлаXML.КонецЭлемента Тогда
		
		ВызватьИсключение НСтр("ru='Ошибка чтения XML'");
		
	КонецЕсли;
	
	// Чтение следующего узла для завершение чтения элемента
	ЧтениеXML.Прочитать();
	
	Если ОбщиеПеременные.Конфигурация.Пустая() Тогда
		
		// Создаем элемент справочника
		Если ЭтоГруппа = Истина Тогда
			
			// Создаем группу
			Конфигурация = Справочники.Конфигурации.СоздатьГруппу();
			
		Иначе
			
			// Создаем элемент справочника
			Конфигурация = Справочники.Конфигурации.СоздатьЭлемент();
			
		КонецЕсли;
		
		// Устанавливаем значение ссылки для нового объекта
		Конфигурация.УстановитьСсылкуНового(КонфигурацияСсылка);
		
	Иначе
		
		// Получим объект по найденной ссылке
		Конфигурация = ОбщиеПеременные.Конфигурация.ПолучитьОбъект();
		
		// Сохраним соответствия уникальных идентификаторов для последующего сопоставления
		УстановитьСоответствиеУИ(КонфигурацияСсылка.УникальныйИдентификатор(), ОбщиеПеременные.Конфигурация.УникальныйИдентификатор(), ОбщиеПеременные);
		
	КонецЕсли;
	
	Если НужноМенятьНаименованиеКонфигурации
		ИЛИ ПустаяСтрока(Конфигурация.Наименование) Тогда
		
		// Наименование
		Конфигурация.Наименование = Наименование;
		
	КонецЕсли;
	
	// Имя
	Конфигурация.Имя = Имя;
	
	Конфигурация.ПометкаУдаления = ПометкаУдаления;
	
	// Синоним
	Конфигурация.Синоним = Синоним;
	
	// Комментарий
	Конфигурация.Комментарий = Комментарий;
	
	// Версия
	Конфигурация.Версия = Версия;
	
	// ДатаОбновления
	Конфигурация.ДатаОбновления = ДатаОбновления;
	
	// Приложение
	Конфигурация.Приложение = Приложение;
	
	Конфигурация.Записать();
	
	ОбщиеПеременные.Вставить("Конфигурация", Конфигурация.Ссылка);
	
	ПолучитьОбъектыКонфигурации(Конфигурация.Ссылка, ОбщиеПеременные);
	
КонецПроцедуры // ПрочитатьКонфигурациюXML()

Процедура ПрочитатьОбъектXML(ЧтениеXML, ОбновлятьСостояние, ОбщиеПеременные)
	
	Перем Объект;
	
	// Проверяем, что текущим узлом является НачалоЭлемента
	Если ЧтениеXML.ТипУзла <> ТипУзлаXML.НачалоЭлемента Тогда
		
		ВызватьИсключение НСтр("ru='Ошибка чтения XML'");
		
	КонецЕсли;
	
	// Если выполняется полная загрузка, то читаем стандартным образом
	Если ОбщиеПеременные.ЗагрузитьНовую Тогда
		
		Объект = ПрочитатьXML(ЧтениеXML);
		Объект.Записать();
		
		
		Возврат;
		
	КонецЕсли;
	
	// Чтение следующего узла
	ЧтениеXML.Прочитать();
	
	// Ref
	ОбъектСсылка = ПрочитатьXML(ЧтениеXML, Тип("СправочникСсылка.Объекты"));
	
	// IsFolder
	ЭтоГруппа = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
	
	// DeletionMark
	ПометкаУдаления = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
	
	// Owner
	Владелец = ПолучитьСсылкуНаОбъект(ПрочитатьXML(ЧтениеXML), ОбщиеПеременные);
	
	// Parent
	Родитель = ПолучитьСсылкуНаОбъект(ПрочитатьXML(ЧтениеXML, Тип("СправочникСсылка.Объекты")), ОбщиеПеременные);
	
	// Description
	Наименование = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Имя
	Имя = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Синоним
	Синоним = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Комментарий
	Комментарий = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Тип
	Тип = ПрочитатьXML(ЧтениеXML, Тип("ПеречислениеСсылка.ТипыОбъектов"));
	
	// Следующие реквизиты для группы не определены
	Если ЭтоГруппа = Ложь Тогда
		
		// Иерархический
		Иерархический = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
		
		// ВидИерархии
		ВидИерархии = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
		
		// ОграничиватьКоличествоУровней
		ОграничиватьКоличествоУровней = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
		
		// КоличествоУровней
		КоличествоУровней = ПрочитатьXML(ЧтениеXML, Тип("Число"));
		
		// СерииКодов
		СерииКодов = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
		
		// КонтрольУникальности
		КонтрольУникальности = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
		
		// АвтоНумерация
		АвтоНумерация = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
		
		// Периодичность
		Периодичность = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
		
		// Подчиненный
		Подчиненный = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
		
	КонецЕсли;
	
	
	// Проверяем, что текущим узлом является КонецЭлемента
	Если ЧтениеXML.ТипУзла <> ТипУзлаXML.КонецЭлемента Тогда
		
		ВызватьИсключение НСтр("ru='Ошибка чтения XML'");
		
	КонецЕсли;
	
	// Чтение следующего узла для завершение чтения элемента
	ЧтениеXML.Прочитать();
	
	мЗапросОбъекты = Новый Запрос(
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Объекты.Ссылка КАК Объект
	|ИЗ
	|	Справочник.Объекты КАК Объекты
	|
	|ГДЕ
	|	Объекты.Имя = &Имя
	|	И Объекты.Владелец = &Владелец
	|	И Объекты.Родитель = &Родитель
	|	И Объекты.ЭтоГруппа = &ЭтоГруппа
	|	И Объекты.Тип = &Тип");
	
	мЗапросОбъекты.УстановитьПараметр("Имя", Имя);
	мЗапросОбъекты.УстановитьПараметр("Владелец", Владелец);
	мЗапросОбъекты.УстановитьПараметр("Родитель", Родитель);
	мЗапросОбъекты.УстановитьПараметр("ЭтоГруппа", ЭтоГруппа);
	мЗапросОбъекты.УстановитьПараметр("Тип", ?(Тип = Неопределено, Перечисления.ТипыОбъектов.ПустаяСсылка(), Тип));
		
	РезультатЗапроса = мЗапросОбъекты.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		
		// Создаем элемент справочника
		Если ЭтоГруппа = Истина Тогда
			
			// Создаем группу
			Объект = Справочники.Объекты.СоздатьГруппу();
			
		Иначе
			
			// Создаем элемент справочника
			Объект = Справочники.Объекты.СоздатьЭлемент();
			
		КонецЕсли;
		
		// Устанавливаем значение ссылки для нового объекта
		Объект.УстановитьСсылкуНового(ОбъектСсылка);
		
		ЗаписыватьЗначение = Истина;
		
	Иначе
		
		// Получим объект по найденной ссылке
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
				
		// Сохраним соответствия уникальных идентификаторов для последующего сопоставления
		УстановитьСоответствиеУИ(ОбъектСсылка.УникальныйИдентификатор(), Выборка.Объект.УникальныйИдентификатор(), ОбщиеПеременные);
		
		Если ОбщиеПеременные.ДобавлятьТолькоНовые Тогда 
			Возврат;
		КонецЕсли;
		
		Объект = Выборка.Объект.ПолучитьОбъект();
		ЗаписыватьЗначение = Ложь;
		
	КонецЕсли;
	
	// Владелец
	УстановитьЗначениеПараметра(Объект.Владелец, Владелец, ЗаписыватьЗначение);
	
	УстановитьЗначениеПараметра(Объект.ПометкаУдаления, ПометкаУдаления, ЗаписыватьЗначение);
				
	// Родитель
	УстановитьЗначениеПараметра(Объект.Родитель, Родитель, ЗаписыватьЗначение);
		
	// Наименование
	УстановитьЗначениеПараметра(Объект.Наименование, Наименование, ЗаписыватьЗначение);
		
	// Имя
	УстановитьЗначениеПараметра(Объект.Имя, Имя, ЗаписыватьЗначение);
		
	// Синоним
	УстановитьЗначениеПараметра(Объект.Синоним, Синоним, ЗаписыватьЗначение);
		
	// Комментарий
	УстановитьЗначениеПараметра(Объект.Комментарий, Комментарий, ЗаписыватьЗначение);
		
	// Тип
	УстановитьЗначениеПараметра(Объект.Тип, Тип, ЗаписыватьЗначение);
		
	// Следующие реквизиты для группы не определены
	Если ЭтоГруппа = Ложь Тогда
		
		// Иерархический
		УстановитьЗначениеПараметра(Объект.Иерархический, Иерархический, ЗаписыватьЗначение);
				
		// ВидИерархии
		УстановитьЗначениеПараметра(Объект.ВидИерархии, ВидИерархии, ЗаписыватьЗначение);
				
		// ОграничиватьКоличествоУровней
		УстановитьЗначениеПараметра(Объект.ОграничиватьКоличествоУровней, ОграничиватьКоличествоУровней, ЗаписыватьЗначение);
				
		// КоличествоУровней
		УстановитьЗначениеПараметра(Объект.КоличествоУровней, КоличествоУровней, ЗаписыватьЗначение);
				
		// СерииКодов
		УстановитьЗначениеПараметра(Объект.СерииКодов, СерииКодов, ЗаписыватьЗначение);
				
		// КонтрольУникальности
		УстановитьЗначениеПараметра(Объект.КонтрольУникальности, КонтрольУникальности, ЗаписыватьЗначение);
				
		// АвтоНумерация
		УстановитьЗначениеПараметра(Объект.АвтоНумерация, АвтоНумерация, ЗаписыватьЗначение);
				
		// Периодичность
		УстановитьЗначениеПараметра(Объект.Периодичность, Периодичность, ЗаписыватьЗначение);
				
		// Подчиненный
		УстановитьЗначениеПараметра(Объект.Подчиненный, Подчиненный, ЗаписыватьЗначение);
				
	КонецЕсли;
	
	Если ЗаписыватьЗначение Тогда
		
		Объект.Записать();
		
	КонецЕсли;
	
	УдалитьИзОбъектовКонфигурации(Объект.Ссылка, ОбщиеПеременные);		
	
КонецПроцедуры // ПрочитатьОбъектXML()

Процедура ПрочитатьСвойствоXML(ЧтениеXML, ОбновлятьСостояние, ОбщиеПеременные)
	
	Перем Свойство;
	
	// Проверяем, что текущим узлом является НачалоЭлемента
	Если ЧтениеXML.ТипУзла <> ТипУзлаXML.НачалоЭлемента Тогда
		
		ВызватьИсключение НСтр("ru='Ошибка чтения XML'");
		
	КонецЕсли;
	
	// Если выполняется полная загрузка, то читаем стандартным образом
	Если ОбщиеПеременные.ЗагрузитьНовую Тогда
		
		Свойство = ПрочитатьXML(ЧтениеXML);
		Свойство.ТипыСтрокой = глТипыСвойстваСтрокой(Свойство);
		Свойство.Записать();
		
		
		Возврат;
		
	КонецЕсли;
	
	// Чтение следующего узла
	ЧтениеXML.Прочитать();
	
	// Ref
	СвойствоСсылка = ПрочитатьXML(ЧтениеXML, Тип("СправочникСсылка.Свойства"));

	// IsFolder
	ЭтоГруппа = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
	
	// DeletionMark
	ПометкаУдаления = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
	
	// Owner
	Владелец = ПолучитьСсылкуНаОбъект(ПрочитатьXML(ЧтениеXML), ОбщиеПеременные);
	
	// Parent
	Родитель = ПолучитьСсылкуНаОбъект(ПрочитатьXML(ЧтениеXML, Тип("СправочникСсылка.Свойства")), ОбщиеПеременные);
	
	// Code
	Код = ПрочитатьXML(ЧтениеXML, Тип("Число"));
	
	// Description
	Наименование = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Синоним
	Синоним = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Комментарий
	Комментарий = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
			
	// Следующие реквизиты для группы не определены
	Если ЭтоГруппа = Ложь Тогда
		
		// Использование
		Использование = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
		
		// Индексирование
		Индексирование = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
		
		// КвалификаторыЧисла_Длина
		КвалификаторыЧисла_Длина = ПрочитатьXML(ЧтениеXML, Тип("Число"));
		
		// КвалификаторыЧисла_Точность
		КвалификаторыЧисла_Точность = ПрочитатьXML(ЧтениеXML, Тип("Число"));
		
		// КвалификаторыЧисла_Неотрицательное
		КвалификаторыЧисла_Неотрицательное = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
		
		// КвалификаторыСтроки_Длина
		КвалификаторыСтроки_Длина = ПрочитатьXML(ЧтениеXML, Тип("Число"));
		
		// КвалификаторыСтроки_Фиксированная
		КвалификаторыСтроки_Фиксированная = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
		
		// КвалификаторыДаты_Состав
		КвалификаторыДаты_Состав = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
		
		// Авторегистрация
		Авторегистрация = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
		
	КонецЕсли;
	
	// Вид
	Вид = ПрочитатьXML(ЧтениеXML, Тип("ПеречислениеСсылка.ВидыСвойств"));
	
	// ТипыСтрокой
	ТипыСтрокой = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	Типы = Новый Массив;
	
	// Типы
	Если ЧтениеXML.Имя = "Типы" И ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		
		// Чтение следующего узла
		ЧтениеXML.Прочитать();
		
		Пока ЧтениеXML.Имя = "Row" И ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Цикл
			
			// Чтение следующего узла
			ЧтениеXML.Прочитать();
			
			Типы.Добавить(ПолучитьСсылкуНаОбъект(ПрочитатьXML(ЧтениеXML, Тип("СправочникСсылка.Объекты")), ОбщиеПеременные));
			
			// Чтение следующего узла для завершение чтения элемента
			ЧтениеXML.Прочитать();
			
		КонецЦикла;
		
		// Чтение следующего узла для завершение чтения элемента
		ЧтениеXML.Прочитать();
		
	КонецЕсли;
	
	// Проверяем, что текущим узлом является КонецЭлемента
	Если ЧтениеXML.ТипУзла <> ТипУзлаXML.КонецЭлемента Тогда
		
		ВызватьИсключение НСтр("ru='Ошибка чтения XML'");
		
	КонецЕсли;
	
	// Чтение следующего узла для завершение чтения элемента
	ЧтениеXML.Прочитать();
	
	ЭтоЭлементСоставаПланаОбмена = Вид = Перечисления.ВидыСвойств.ЭлементСоставаПланаОбмена И Наименование <> "{Состав}";
	
	Если ЭтоЭлементСоставаПланаОбмена Тогда
		
		ЗапросСвойства = Новый Запрос(
			"ВЫБРАТЬ
			|	Свойства.Ссылка КАК Свойство
			|ИЗ
			|	Справочник.Свойства КАК Свойства
			|ГДЕ
			|	Свойства.Наименование = &Наименование
			|	И Свойства.Владелец = &Владелец
			|	И Свойства.Родитель = &Родитель
			|	И Свойства.ЭтоГруппа = &ЭтоГруппа
			|	И Свойства.Вид = &Вид
			|	И Свойства.Типы.Тип = &Тип");
		ЗапросСвойства.УстановитьПараметр("Тип", Типы[0]);
		
	Иначе
		
		ЗапросСвойства = Новый Запрос(
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Свойства.Ссылка КАК Свойство
		|ИЗ
		|	Справочник.Свойства КАК Свойства
		|
		|ГДЕ
		|	Свойства.Наименование = &Наименование
		|	И Свойства.Владелец = &Владелец
		|	И Свойства.Родитель = &Родитель
		|	И Свойства.ЭтоГруппа = &ЭтоГруппа
		|	И Свойства.Вид = &Вид");
		
	КонецЕсли;
	
	ЗапросСвойства.УстановитьПараметр("Наименование", Наименование);
	ЗапросСвойства.УстановитьПараметр("Владелец", Владелец);
	ЗапросСвойства.УстановитьПараметр("Родитель", Родитель);
	ЗапросСвойства.УстановитьПараметр("ЭтоГруппа", ЭтоГруппа);
	ЗапросСвойства.УстановитьПараметр("Вид", Вид);
	
	РезультатЗапроса = ЗапросСвойства.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		
		// Создаем элемент справочника
		Если ЭтоГруппа = Истина Тогда
			
			// Создаем группу
			Свойство = Справочники.Свойства.СоздатьГруппу();
			
		Иначе
			
			// Создаем элемент справочника
			Свойство = Справочники.Свойства.СоздатьЭлемент();
			
		КонецЕсли;
		
		// Устанавливаем значение ссылки для нового объекта
		Свойство.УстановитьСсылкуНового(СвойствоСсылка);
		
		ЗаписыватьЗначение = Истина;
		
	Иначе
		
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		СвойствоВыборки = Выборка.Свойство;
		
		// Сохраним соответствия уникальных идентификаторов для последующего сопоставления
		УстановитьСоответствиеУИ(СвойствоСсылка.УникальныйИдентификатор(), СвойствоВыборки.УникальныйИдентификатор(), ОбщиеПеременные);
		
		Если ОбщиеПеременные.ДобавлятьТолькоНовые Тогда
			Возврат;
		КонецЕсли;
		
		Свойство = СвойствоВыборки.ПолучитьОбъект();
		
		ЗаписыватьЗначение = Ложь;
		
	КонецЕсли;
	
	// Владелец
	УстановитьЗначениеПараметра(Свойство.Владелец, Владелец, ЗаписыватьЗначение);
	
	УстановитьЗначениеПараметра(Свойство.ПометкаУдаления, ПометкаУдаления, ЗаписыватьЗначение);
			
	// Родитель
	УстановитьЗначениеПараметра(Свойство.Родитель, Родитель, ЗаписыватьЗначение);
		
	// Код
	Свойство.Код = Код; // это свойство ни на что не влияет
			
	// Наименование
	УстановитьЗначениеПараметра(Свойство.Наименование, Наименование, ЗаписыватьЗначение);
		
	// Синоним
	УстановитьЗначениеПараметра(Свойство.Синоним, Синоним, ЗаписыватьЗначение);
		
	// Комментарий
	УстановитьЗначениеПараметра(Свойство.Комментарий, Комментарий, ЗаписыватьЗначение);
				
	// Следующие реквизиты для группы не определены
	Если ЭтоГруппа = Ложь Тогда
		
		// Использование
		УстановитьЗначениеПараметра(Свойство.Использование, Использование, ЗаписыватьЗначение);
				
		// Индексирование
		УстановитьЗначениеПараметра(Свойство.Индексирование, Индексирование, ЗаписыватьЗначение);
				
		// КвалификаторыЧисла_Длина
		УстановитьЗначениеПараметра(Свойство.КвалификаторыЧисла_Длина, КвалификаторыЧисла_Длина, ЗаписыватьЗначение);
				
		// КвалификаторыЧисла_Точность
		УстановитьЗначениеПараметра(Свойство.КвалификаторыЧисла_Точность, КвалификаторыЧисла_Точность, ЗаписыватьЗначение);
				
		// КвалификаторыЧисла_Неотрицательное
		УстановитьЗначениеПараметра(Свойство.КвалификаторыЧисла_Неотрицательное, КвалификаторыЧисла_Неотрицательное, ЗаписыватьЗначение);
				
		// КвалификаторыСтроки_Длина
		УстановитьЗначениеПараметра(Свойство.КвалификаторыСтроки_Длина, КвалификаторыСтроки_Длина, ЗаписыватьЗначение);
				
		// КвалификаторыСтроки_Фиксированная
		УстановитьЗначениеПараметра(Свойство.КвалификаторыСтроки_Фиксированная, КвалификаторыСтроки_Фиксированная, ЗаписыватьЗначение);
				
		// КвалификаторыДаты_Состав
		УстановитьЗначениеПараметра(Свойство.КвалификаторыДаты_Состав, КвалификаторыДаты_Состав, ЗаписыватьЗначение);
				
		// Авторегистрация
		УстановитьЗначениеПараметра(Свойство.Авторегистрация, Авторегистрация, ЗаписыватьЗначение);
				
	КонецЕсли;
	
	// Вид
	УстановитьЗначениеПараметра(Свойство.Вид, Вид, ЗаписыватьЗначение);
		
	// Типы
	
	Если Свойство.Типы.Количество() <> Типы.Количество() Тогда
		
		ЗаписыватьЗначение = Истина;
		
		Свойство.Типы.Очистить();
		
		Для Индекс = 0 По Типы.Количество() - 1 Цикл
			
			Свойство.Типы.Добавить().Тип = Типы[Индекс];
			
		КонецЦикла;
		
	Иначе
		
		Для Индекс = 0 По Типы.Количество() - 1 Цикл
			
			УстановитьЗначениеПараметра(Свойство.Типы[Индекс].Тип, Типы[Индекс], ЗаписыватьЗначение);
						
		КонецЦикла;
		
		
	КонецЕсли;
	
	// ТипыСтрокой
	УстановитьЗначениеПараметра(Свойство.ТипыСтрокой, глТипыСвойстваСтрокой(Свойство), ЗаписыватьЗначение);
	
	Если ЗаписыватьЗначение Тогда
		
		Свойство.Записать();
		
	КонецЕсли;
	
	УдалитьИзОбъектовКонфигурации(Свойство.Ссылка, ОбщиеПеременные);		
	
КонецПроцедуры // ПрочитатьСвойствоXML()

Процедура УстановитьЗначениеПараметра(ТекущийПараметр, НовыйПараметр, ЗначениеИзменено)
	
	Если ТекущийПараметр <> НовыйПараметр Тогда
		
		ТекущийПараметр = НовыйПараметр;
		ЗначениеИзменено = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПрочитатьЗначениеXML(ЧтениеXML, ОбновлятьСостояние, ОбщиеПеременные)
	
	Перем Значение;
	
	// Проверяем, что текущим узлом является НачалоЭлемента
	Если ЧтениеXML.ТипУзла <> ТипУзлаXML.НачалоЭлемента Тогда
		
		ВызватьИсключение НСтр("ru='Ошибка чтения XML'");
		
	КонецЕсли;
	
	// Если выполняется полная загрузка, то читаем стандартным образом
	Если ОбщиеПеременные.ЗагрузитьНовую Тогда
		
		Значение = ПрочитатьXML(ЧтениеXML);
		Значение.Записать();
		
		Возврат;
		
	КонецЕсли;
	
	// Чтение следующего узла
	ЧтениеXML.Прочитать();
	
	// Ref
	ЗначениеСсылка = ПрочитатьXML(ЧтениеXML, Тип("СправочникСсылка.Значения"));

	// DeletionMark
	ПометкаУдаления = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
	
	// Owner
	Владелец = ПолучитьСсылкуНаОбъект(ПрочитатьXML(ЧтениеXML), ОбщиеПеременные);
	
	// Parent
	Родитель = ПолучитьСсылкуНаОбъект(ПрочитатьXML(ЧтениеXML, Тип("СправочникСсылка.Значения")), ОбщиеПеременные);
	
	// Code
	Код = ПрочитатьXML(ЧтениеXML, Тип("Число"));
	
	// Description
	Наименование = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Синоним
	Синоним = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Комментарий
	Комментарий = ПрочитатьXML(ЧтениеXML, Тип("Строка"));
	
	// Предопределенное
	Предопределенное = ПрочитатьXML(ЧтениеXML, Тип("Булево"));
	
	// Типы
	// Чтение следующего узла
	ЧтениеXML.Прочитать();
	// Чтение следующего узла для завершение чтения элемента
	ЧтениеXML.Прочитать();
	
	// Проверяем, что текущим узлом является КонецЭлемента
	Если ЧтениеXML.ТипУзла <> ТипУзлаXML.КонецЭлемента Тогда
		
		ВызватьИсключение НСтр("ru='Ошибка чтения XML'");
		
	КонецЕсли;
	
	// Чтение следующего узла для завершение чтения элемента
	ЧтениеXML.Прочитать();
	мЗапросЗначения = Новый Запрос(
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Значения.Ссылка КАК Значение
		|ИЗ
		|	Справочник.Значения КАК Значения
		|
		|ГДЕ
		|	Значения.Наименование = &Наименование
		|	И Значения.Владелец = &Владелец");
	мЗапросЗначения.УстановитьПараметр("Наименование", Наименование);
	мЗапросЗначения.УстановитьПараметр("Владелец", Владелец);
	
	РезультатЗапроса = мЗапросЗначения.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		
		// Создаем элемент справочника
		Значение = Справочники.Значения.СоздатьЭлемент();
		
		// Устанавливаем значение ссылки для нового объекта
		Значение.УстановитьСсылкуНового(ЗначениеСсылка);
		
		ЗаписыватьЗначение = Истина;
		
	Иначе
		
		// Получим объект по найденной ссылке
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
				
		// Сохраним соответствия уникальных идентификаторов для последующего сопоставления
		УстановитьСоответствиеУИ(ЗначениеСсылка.УникальныйИдентификатор(), Выборка.Значение.УникальныйИдентификатор(), ОбщиеПеременные);
		
		Если ОбщиеПеременные.ДобавлятьТолькоНовые Тогда 
			Возврат;
		КонецЕсли;

		Значение = Выборка.Значение.ПолучитьОбъект();
		ЗаписыватьЗначение = Ложь;
		
	КонецЕсли;
	
	// Владелец
	УстановитьЗначениеПараметра(Значение.Владелец, Владелец, ЗаписыватьЗначение);
	
	УстановитьЗначениеПараметра(Значение.ПометкаУдаления, ПометкаУдаления, ЗаписыватьЗначение);
				
	// Родитель
	УстановитьЗначениеПараметра(Значение.Родитель, Родитель, ЗаписыватьЗначение);
		
	// Код
	Значение.Код = Код;
			
	// Наименование
	УстановитьЗначениеПараметра(Значение.Наименование, Наименование, ЗаписыватьЗначение);
		
	// Синоним
	УстановитьЗначениеПараметра(Значение.Синоним, Синоним, ЗаписыватьЗначение);
		
	// Комментарий
	УстановитьЗначениеПараметра(Значение.Комментарий, Комментарий, ЗаписыватьЗначение);
		
	// Предопределенное
	УстановитьЗначениеПараметра(Значение.Предопределенное, Предопределенное, ЗаписыватьЗначение);
	
	Если ЗаписыватьЗначение Тогда
	
		Значение.Записать();
	
	КонецЕсли;
	
	УдалитьИзОбъектовКонфигурации(Значение.Ссылка, ОбщиеПеременные);		
	
КонецПроцедуры // ПрочитатьЗначениеXML()

Функция ПолучитьСсылкуНаОбъект(Объект, ОбщиеПеременные)
	
	УИ = ОбщиеПеременные.СоответствиеУИ[Строка(Объект.УникальныйИдентификатор())];
	
	Если УИ = Неопределено Тогда
		
		Возврат Объект;
		
	Иначе
		
		ЧтениеXML = Новый ЧтениеXML;
		ЧтениеXML.УстановитьСтроку("<Ref>" + УИ + "</Ref>");
		
		Возврат ПрочитатьXML(ЧтениеXML, ТипЗнч(Объект));
		
	КонецЕсли;
	
КонецФункции // ПолучитьСсылкуНаОбъект()

Процедура УстановитьСоответствиеУИ(УИЗагруженный, УИСуществующий, ОбщиеПеременные)
	
	ОбщиеПеременные.СоответствиеУИ.Вставить(Строка(УИЗагруженный), Строка(УИСуществующий));
	
КонецПроцедуры // УстановитьСоответствиеУИ()

Процедура ПолучитьОбъектыКонфигурации(Конфигурация, ОбщиеПеременные)
	
	Если ОбщиеПеременные.ЗагрузитьНовую
		ИЛИ ОбщиеПеременные.ДобавлятьТолькоНовые Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	Объекты.Ссылка
	                      |ИЗ
	                      |	Справочник.Объекты КАК Объекты
	                      |ГДЕ
	                      |	Объекты.Владелец = &Конфигурация
	                      |	И Объекты.ЭтоГруппа = ЛОЖЬ
	                      |	И Объекты.ПометкаУдаления = ЛОЖЬ
	                      |
	                      |ОБЪЕДИНИТЬ ВСЕ
	                      |
	                      |ВЫБРАТЬ
	                      |	Свойства.Ссылка
	                      |ИЗ
	                      |	Справочник.Свойства КАК Свойства
	                      |ГДЕ
	                      |	Свойства.Владелец.Владелец = &Конфигурация
	                      |	И Свойства.ПометкаУдаления = ЛОЖЬ
	                      |
	                      |ОБЪЕДИНИТЬ ВСЕ
	                      |
	                      |ВЫБРАТЬ
	                      |	Значения.Ссылка
	                      |ИЗ
	                      |	Справочник.Значения КАК Значения
	                      |ГДЕ
	                      |	Значения.Владелец.Владелец = &Конфигурация
	                      |	И Значения.ПометкаУдаления = ЛОЖЬ");
	
	Запрос.УстановитьПараметр("Конфигурация", Конфигурация);
	
	мОбъектыКонфигурации = Запрос.Выполнить().Выгрузить();
	
	мОбъектыКонфигурации.Индексы.Добавить("Ссылка");
	ОбщиеПеременные.Вставить("ОбъектыКонфигурации", мОбъектыКонфигурации);
КонецПроцедуры // ПолучитьОбъектыКонфигурации()

Процедура УдалитьИзОбъектовКонфигурации(Объект, ОбщиеПеременные)
	
	Если ОбщиеПеременные.ЗагрузитьНовую
		ИЛИ ОбщиеПеременные.ДобавлятьТолькоНовые Тогда
		
		Возврат;
		
	КонецЕсли;
	
	НайденнаяСтрока = ОбщиеПеременные.ОбъектыКонфигурации.Найти(Объект, "Ссылка");
	
	Если НайденнаяСтрока <> Неопределено Тогда
		
		ОбщиеПеременные.ОбъектыКонфигурации.Удалить(НайденнаяСтрока);
		
	КонецЕсли;
	
КонецПроцедуры // УдалитьИзОбъектовКонфигурации()

#КонецОбласти

#КонецЕсли