package com.example.backend.repository;

import com.example.backend.model.ReadingMaterial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReadingMaterialRepository extends JpaRepository<ReadingMaterial, Integer> {
}
