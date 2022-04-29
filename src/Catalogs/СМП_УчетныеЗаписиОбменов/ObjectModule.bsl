
#Область ПрограммныйИнтерфейс

// Помещает СКД для выбранных документов в ТЧ объекта.
//
// Параметры:
//   КоллекцияСКД - Структура - содержит адреса временных хранилищ СКД для выбранных документов.
//
Процедура ПоместитьСКДВТабЧасть(КоллекцияСКД) Экспорт
	
	Для Каждого СтрокаТЧ Из ОбъектыКВыгрузке Цикл
		
		АдресСхемыКД = Неопределено;
		КоллекцияСКД.Свойство(СтрокаТЧ.ИмяОбъекта, АдресСхемыКД);
		Если ЭтоАдресВременногоХранилища(АдресСхемыКД) Тогда
			
			СКД = ПолучитьИзВременногоХранилища(АдресСхемыКД);
			Если СКД <> Неопределено Тогда
				
				ХранилищеСхемы = Новый ХранилищеЗначения(СКД);
				СтрокаТЧ.СКДДляотборов = ХранилищеСхемы;
				
			Иначе
				
				СтрокаТЧ.СКДДляОтборов = Неопределено;
				
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры //ПоместитьСКДВТабЧасть

// Получает СКД из таб. части и помещает их во временные хранилища.
//
// Параметры:
//   КоллекцияОбъектовНаФорме - ТаблицаЗначений - реквизит формы "ОбъектыКВыгрузкеНаФорме".
//   КоллекцияСКД - Структура - предназначена для хранения аресов временных хранилищ схем КД выбранных документов.
//   ИдентификаторФормы - УникальныйИдентификатор - идентификатор формы для привязки временных хранилищ.
//
Процедура ПолучитьСКДИзТабЧасти(КоллекцияОбъектовНаФорме, КоллекцияСКД, ИдентификаторФормы) Экспорт
	
	Для Каждого СтрокаТЧ Из ОбъектыКВыгрузке Цикл
		ИскомаяСтр = КоллекцияОбъектовНаФорме.Найти(СтрокаТЧ.ПолноеИмяОбъекта, "ПолноеИмяОбъекта");
		Если ИскомаяСтр <> Неопределено Тогда
			ИскомаяСтр.Пометка = Истина;
			
			СКД = СтрокаТЧ.СкдДляОтборов.Получить();
			Если ТипЗнч(СКД) = Тип("СхемаКомпоновкиДанных") Тогда
				АдресСхемыКД = ПоместитьВоВременноеХранилище(СКД, ИдентификаторФормы);
				КоллекцияСКД.Вставить(СтрокаТЧ.ИмяОбъекта, АдресСхемыКД);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры //ПолучитьСКДИзТабЧасти

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если НастройкаОбмена = Перечисления.СМП_НастройкиОбменов.ДляОтправки Тогда
		индИсточник = ПроверяемыеРеквизиты.Найти("Источник");
		ПроверяемыеРеквизиты.Удалить(индИсточник);
	КонецЕсли;
	
КонецПроцедуры


Процедура ПриЗаписи(Отказ)
	
	// Временно:
	ОбновитьПовторноИспользуемыеЗначения();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
// Код процедур и функций
#КонецОбласти
