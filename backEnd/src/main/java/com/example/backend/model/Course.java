package com.example.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "courses", schema = "elearningmanagerment")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Course {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "course_id")
    private Integer courseId;

    @Column( nullable = false, length = 255)
    private String title;

    @Column( nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column( columnDefinition = "TEXT")
    private String thumbnail;

    @Column( nullable = false, length = 20)
    private String status;

    @Column( name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column( name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "instructor_id", nullable = false)
    private User instructor;

    @PrePersist
    protected void onCreate(){
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate(){
        updatedAt = LocalDateTime.now();
    }
}
