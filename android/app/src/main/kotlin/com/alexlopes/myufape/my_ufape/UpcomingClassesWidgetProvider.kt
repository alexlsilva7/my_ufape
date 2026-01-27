package com.alexlopes.myufape.my_ufape

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

/**
 * AppWidgetProvider para o widget de Próximas Aulas.
 */
class UpcomingClassesWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        Log.d("WidgetProvider", "onUpdate chamado com ${appWidgetIds.size} widgets")
        
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.upcoming_classes_widget)
                
                // 1. Configurar Intent para abrir o App ao clicar no Widget
                // Aponta para /home para evitar erro de rota inexistente no Routefly
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("myufape://widget/timetable?widget_id=$appWidgetId")
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
                
                // 2. Ler dados via widgetData
                val jsonString = widgetData.getString(UPCOMING_CLASSES_KEY, "[]") ?: "[]"
                Log.d("WidgetProvider", "JSON lido no widget $appWidgetId: $jsonString")
                
                val classes = JSONArray(jsonString)
                val count = classes.length()
                Log.d("WidgetProvider", "Classes encontradas: $count")

                // Atualizar título
                views.setTextViewText(R.id.widget_title, "Próximas Aulas")
                
                if (count == 0) {
                    Log.d("WidgetProvider", "Mostrando estado vazio")
                    showEmptyState(views)
                } else {
                    Log.d("WidgetProvider", "Escondendo mensagem vazia")
                    views.setViewVisibility(R.id.empty_message, View.GONE)
                    
                    // Atualizar cada aula (limite de 3)
                    for (i in 0 until 3) {
                        if (i < count) {
                            val classData = classes.getJSONObject(i)
                            updateClassView(views, i + 1, classData)
                        } else {
                            hideClassView(views, i + 1)
                        }
                    }
                }

                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d("WidgetProvider", "Widget $appWidgetId atualizado com sucesso no Manager")
                
            } catch (e: Exception) {
                Log.e("WidgetProvider", "Erro no onUpdate do widget $appWidgetId: ${e.message}", e)
                try {
                    val errorViews = RemoteViews(context.packageName, R.layout.upcoming_classes_widget)
                    showEmptyState(errorViews)
                    appWidgetManager.updateAppWidget(appWidgetId, errorViews)
                } catch (e2: Exception) {
                    Log.e("WidgetProvider", "Erro ao mostrar fallback: ${e2.message}")
                }
            }
        }
    }

    private fun showEmptyState(views: RemoteViews) {
        views.setViewVisibility(R.id.empty_message, View.VISIBLE)
        views.setViewVisibility(R.id.class_1_container, View.GONE)
        views.setViewVisibility(R.id.class_2_container, View.GONE)
        views.setViewVisibility(R.id.class_3_container, View.GONE)
    }

    private fun updateClassView(views: RemoteViews, index: Int, classData: JSONObject) {
        val containerId = when (index) {
            1 -> R.id.class_1_container
            2 -> R.id.class_2_container
            else -> R.id.class_3_container
        }
        val badgeId = when (index) {
            1 -> R.id.class_1_badge
            2 -> R.id.class_2_badge
            else -> R.id.class_3_badge
        }
        val nameId = when (index) {
            1 -> R.id.class_1_name
            2 -> R.id.class_2_name
            else -> R.id.class_3_name
        }
        val timeId = when (index) {
            1 -> R.id.class_1_time
            2 -> R.id.class_2_time
            else -> R.id.class_3_time
        }
        val indicatorId = when (index) {
            1 -> R.id.class_1_indicator
            2 -> R.id.class_2_indicator
            else -> R.id.class_3_indicator
        }
        val contentId = when (index) {
            1 -> R.id.class_1_content
            2 -> R.id.class_2_content
            else -> R.id.class_3_content
        }

        val subjectName = classData.optString("subjectName", "Aula")
        val startTime = classData.optString("startTime", "--:--")
        val endTime = classData.optString("endTime", "--:--")
        val isOngoing = classData.optBoolean("isOngoing", false)
        val dayLabel = classData.optString("dayLabel", "")
        val classContent = classData.optString("classContent", "")

        val badge = when {
            isOngoing -> "AGORA"
            dayLabel.isNotEmpty() -> dayLabel.uppercase()
            else -> "AULA"
        }

        // Cor do indicador (ARGB)
        val indicatorColor = if (isOngoing) 0xFFF57C00.toInt() else 0xFF2196F3.toInt()

        Log.d("WidgetProvider", "Desenhando item $index: $subjectName ($badge)")
        
        views.setViewVisibility(containerId, View.VISIBLE)
        views.setTextViewText(badgeId, badge)
        views.setTextViewText(nameId, subjectName)
        views.setTextViewText(timeId, "$startTime - $endTime")
        views.setInt(indicatorId, "setBackgroundColor", indicatorColor)

        if (classContent.isNotEmpty()) {
            views.setTextViewText(contentId, classContent)
            views.setViewVisibility(contentId, View.VISIBLE)
        } else {
            views.setViewVisibility(contentId, View.GONE)
        }
    }

    private fun hideClassView(views: RemoteViews, index: Int) {
        val containerId = when (index) {
            1 -> R.id.class_1_container
            2 -> R.id.class_2_container
            else -> R.id.class_3_container
        }
        views.setViewVisibility(containerId, View.GONE)
    }

    companion object {
        private const val UPCOMING_CLASSES_KEY = "upcoming_classes_data"
    }
}
