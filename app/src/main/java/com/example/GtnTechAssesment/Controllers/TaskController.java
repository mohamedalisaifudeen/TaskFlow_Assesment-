package com.example.GtnTechAssesment.Controllers;

import com.example.GtnTechAssesment.Dto.TaskRequestDto;
import com.example.GtnTechAssesment.Dto.TaskResponseDto;
import com.example.GtnTechAssesment.Service.TaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
@Tag(name = "Tasks", description = "TaskFlow Management REST APIs")
public class TaskController {
    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @PostMapping
    @Operation(summary = "Create a new task")
    public ResponseEntity<TaskResponseDto> createTask(@Valid @RequestBody TaskRequestDto request){
        return new ResponseEntity<>(taskService.createTask(request), HttpStatus.CREATED);
    }

    @GetMapping
    @Operation(summary = "List all tasks")
    public ResponseEntity<List<TaskResponseDto>> getAll(){
        return ResponseEntity.ok(taskService.getAllTask());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get task by ID")
    public ResponseEntity<TaskResponseDto> getTaskById(@PathVariable Long id){
        return ResponseEntity.ok(taskService.getTaskById(id));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update task by ID")
    public ResponseEntity<TaskResponseDto> updateTask(@PathVariable Long id,@Valid @RequestBody TaskRequestDto request){
        return ResponseEntity.ok(taskService.updateTask(id,request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete task by ID")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id){
        taskService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }

}
