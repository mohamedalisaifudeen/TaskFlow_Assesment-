package com.example.GtnTechAssesment.Dto;

import com.example.GtnTechAssesment.Enum.TaskStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;


@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TaskRequestDto {
    @NotBlank(message = "Title is required")
    @Size(max = 100,min = 3,message = "Title must be withing 3-100 characters ")
    private String title;
    @Size(max = 500,message = "Description cannot exceed 500 characters")
    private String description;
    @NotNull(message = "Status is required (TODO , IN_PROGRESS, COMPLETED)")
    private TaskStatus status;
}
