package com.example.GtnTechAssesment.Service;

import com.example.GtnTechAssesment.Dto.TaskRequestDto;
import com.example.GtnTechAssesment.Dto.TaskResponseDto;
import com.example.GtnTechAssesment.Entity.Task;
import com.example.GtnTechAssesment.Repo.TaskRepository;

import com.example.GtnTechAssesment.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TaskService {
    private final TaskRepository taskRepository;

    public TaskResponseDto createTask(TaskRequestDto request){
        Task task=Task.builder()
                .title(request.getTitle())
                .decription(request.getDescription())
                .status(request.getStatus())
                .build();
        return maptoDto(taskRepository.save(task));
    }

    @Transactional(readOnly = true)
    public List<TaskResponseDto> getAllTask(){
        return taskRepository.findAll().stream()
                .map(this::maptoDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public TaskResponseDto getTaskById(Long id){
        Task task =taskRepository.findById(id).orElseThrow();
        return maptoDto(task);
    }

    @Transactional
    public TaskResponseDto updateTask(Long id,TaskRequestDto request){
        Task task=taskRepository.findById(id).orElseThrow();
        task.setTitle(request.getTitle());
        task.setDecription(request.getDescription());
        task.setStatus(request.getStatus());
        return maptoDto(taskRepository.save(task));
    }

    @Transactional
    public void deleteTask(Long id){
        if(!taskRepository.existsById(id)){
            throw new RuntimeException("Task with id "+id+" Not Found");
        }
        taskRepository.deleteById(id);
    }

    private TaskResponseDto maptoDto(Task task){
        return TaskResponseDto.builder()
                .title(task.getTitle())
                .description(task.getDecription())
                .id(task.getId())
                .status(task.getStatus())
                .createdAt(task.getCreatedAt())
                .updatedAt(task.getUpdatedAt())
                .build();
    }
}
