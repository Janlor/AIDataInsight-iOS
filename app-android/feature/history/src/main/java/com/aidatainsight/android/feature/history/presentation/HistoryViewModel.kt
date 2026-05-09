package com.aidatainsight.android.feature.history.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aidatainsight.android.feature.history.application.usecase.DeleteAllHistoryUseCase
import com.aidatainsight.android.feature.history.application.usecase.DeleteHistoryUseCase
import com.aidatainsight.android.feature.history.application.usecase.LoadHistoryPageUseCase
import com.aidatainsight.android.feature.history.data.DefaultHistoryRepository
import com.aidatainsight.android.feature.history.domain.HistoryRepository
import com.aidatainsight.android.feature.history.application.model.HistoryRecordGroup
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class HistoryViewModel(
    repository: HistoryRepository = DefaultHistoryRepository(),
) : ViewModel() {
    private val loadHistoryPage = LoadHistoryPageUseCase(repository)
    private val deleteHistory = DeleteHistoryUseCase(repository)
    private val deleteAllHistory = DeleteAllHistoryUseCase(repository)
    private var recordGroups: List<HistoryRecordGroup> = emptyList()
    private var currentPage: Int = 1

    private val _uiState = MutableStateFlow(HistoryUiState())
    val uiState: StateFlow<HistoryUiState> = _uiState.asStateFlow()

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            runCatching {
                loadHistoryPage(
                    currentPage = 1,
                    pageSize = DEFAULT_PAGE_SIZE,
                    existingGroups = emptyList(),
                )
            }.onSuccess { snapshot ->
                currentPage = snapshot.page?.currentPage ?: 1
                recordGroups = snapshot.groups
                _uiState.value = HistoryUiState(
                    sections = HistoryListBuilder.makeSections(recordGroups),
                    isLoading = false,
                    hasMore = hasMore(snapshot.page?.currentPage, snapshot.page?.pages),
                )
            }.onFailure { error ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = error.message ?: "加载失败",
                )
            }
        }
    }

    fun loadMore() {
        if (_uiState.value.isLoadingMore || !_uiState.value.hasMore) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingMore = true, errorMessage = null)
            val nextPage = currentPage + 1
            runCatching {
                loadHistoryPage(
                    currentPage = nextPage,
                    pageSize = DEFAULT_PAGE_SIZE,
                    existingGroups = recordGroups,
                )
            }.onSuccess { snapshot ->
                currentPage = snapshot.page?.currentPage ?: nextPage
                recordGroups = snapshot.groups
                _uiState.value = _uiState.value.copy(
                    sections = HistoryListBuilder.makeSections(recordGroups),
                    isLoadingMore = false,
                    hasMore = hasMore(snapshot.page?.currentPage, snapshot.page?.pages),
                )
            }.onFailure { error ->
                _uiState.value = _uiState.value.copy(
                    isLoadingMore = false,
                    errorMessage = error.message ?: "加载失败",
                )
            }
        }
    }

    fun delete(id: String) {
        val historyId = id.toIntOrNull() ?: return
        viewModelScope.launch {
            runCatching {
                deleteHistory(historyId = historyId, existingGroups = recordGroups)
            }.onSuccess { output ->
                recordGroups = output.state.groups
                _uiState.value = _uiState.value.copy(
                    sections = HistoryListBuilder.makeSections(recordGroups),
                    errorMessage = null,
                )
            }.onFailure { error ->
                _uiState.value = _uiState.value.copy(errorMessage = error.message ?: "删除失败")
            }
        }
    }

    fun deleteAll() {
        viewModelScope.launch {
            runCatching { deleteAllHistory() }
                .onSuccess { snapshot ->
                    recordGroups = snapshot.groups
                    _uiState.value = _uiState.value.copy(
                        sections = emptyList(),
                        hasMore = false,
                        errorMessage = null,
                    )
                }
                .onFailure { error ->
                    _uiState.value = _uiState.value.copy(errorMessage = error.message ?: "清空失败")
                }
        }
    }

    fun dismissError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }

    private fun hasMore(currentPage: Int?, pages: Int?): Boolean {
        return currentPage != null && pages != null && currentPage < pages
    }

    private companion object {
        const val DEFAULT_PAGE_SIZE = 20
    }
}
