package com.example.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "enrollments", schema = "elearningmanagerment",
       uniqueConstraints = {@UniqueConstraint(columnNames = {"student_id", "course_id"})})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Enrollments {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "enrollment_id")
    private Integer enrollmentId;

    @Column(name = "enroll_date", nullable = false, updatable = false)
    private LocalDateTime enrollDate;

    @Column(nullable = false)
    private Boolean status = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @PrePersist
    protected void onCreate(){
        enrollDate = LocalDateTime.now();
    }
}
