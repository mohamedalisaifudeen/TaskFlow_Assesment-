package com.example.GtnTechAssesment.Entity;

import com.example.GtnTechAssesment.Enum.TaskStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.cglib.core.Local;

import java.time.LocalDateTime;

@Entity
@Table(name="task")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(nullable = false,length = 100)
    private String title;

    @Column(length = 500)
    private String decription;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskStatus status;

    @Column(nullable = false,updatable = false,name ="created_at")
    private LocalDateTime createdAt;

    @Column(name="updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate(){
        this.createdAt=LocalDateTime.now();
        this.updatedAt=LocalDateTime.now();
        if(status==null){
            this.status=TaskStatus.TODO;
        }
    }

    @PreUpdate
    protected void onUpdate(){
        this.updatedAt=LocalDateTime.now();
    }
}
