
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	мРеквизиты = Новый Структура("ОбъектИсточник, ОбъектПриемник", "Источник", "Приемник");
	ДанныеРеквизитов = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Объект.Владелец, мРеквизиты);
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеРеквизитов);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФорм

&НаКлиенте
Процедура ПриемникНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Оповещение = Новый ОписаниеОповещения("ПриемникНачалоВыбораЗавершение", ЭтотОбъект);
	мПараметрыФормы = Новый Структура("ВидОбъектаОбмена, ИмяРодительскогоОбъекта",
	ПредопределенноеЗначение("Перечисление.СМП_ВидыОбъектовОбмена.ПредопределенноеЗначение"), ОбъектПриемник);
	ОткрытьФорму("ОбщаяФорма.СМП_ФормаВыбораПриемника", мПараметрыФормы, Элемент,,,, Оповещение);
	
КонецПроцедуры

// Обработчик оповещения.
//
&НаКлиенте
Процедура ПриемникНачалоВыбораЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если РезультатЗакрытия <> Неопределено Тогда
		Объект.Приемник = РезультатЗакрытия.Имя;
		Если НЕ Модифицированность Тогда
			Модифицированность = Истина;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры //ПриемникНачалоВыбораЗавершение

&НаКлиенте
Процедура КомментарийНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ОбщегоНазначенияКлиент.ПоказатьФормуРедактированияКомментария(Элемент.ТекстРедактирования, ЭтотОбъект, "Объект.Комментарий");
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции


#КонецОбласти
