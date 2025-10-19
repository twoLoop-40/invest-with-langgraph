# Idris 2 학습 가이드

이 프로젝트에서 Idris를 직접 수정하고 관리하기 위한 실전 가이드입니다.

## 목차
1. [Idris 기초 문법](#idris-기초-문법)
2. [이 프로젝트에서 사용하는 패턴](#이-프로젝트에서-사용하는-패턴)
3. [자주 하는 작업](#자주-하는-작업)
4. [컴파일 에러 해결](#컴파일-에러-해결)
5. [실전 예제](#실전-예제)

---

## Idris 기초 문법

### 1. 모듈과 타입 정의

```idris
module NotebookStructure  -- 모듈 이름 (파일 이름과 같아야 함)

%default total  -- 모든 함수가 total(완전)해야 함

-- 타입 별칭 (Type Alias)
CellIndex : Type
CellIndex = Nat  -- Nat는 자연수 (0, 1, 2, ...)

-- Record 정의 (구조체와 비슷)
record Section where
  constructor MkSection
  markdownIdx : CellIndex
  codeIndices : List CellIndex
```

### 2. 함수 정의

```idris
-- 간단한 함수
double : Nat -> Nat
double n = n + n

-- 리스트 처리
length : List a -> Nat
length [] = 0
length (x :: xs) = 1 + length xs

-- 조건부 (Bool 반환)
isAscending : List Nat -> Bool
isAscending [] = True
isAscending [x] = True
isAscending (x :: y :: rest) =
  x < y && isAscending (y :: rest)
```

### 3. 패턴 매칭

```idris
-- 리스트 패턴
matchList : List a -> String
matchList [] = "Empty"
matchList [x] = "Single"
matchList (x :: y :: rest) = "Multiple"

-- Record 패턴
getMarkdown : Section -> CellIndex
getMarkdown s = s.markdownIdx  -- s.필드명으로 접근
```

### 4. 타입 검증 함수

```idris
-- Bool 반환 함수 (런타임 검증용)
isValid : List PracticeProblem -> Bool
isValid problems =
  length problems == 10 &&
  isAscending (map problemNumber problems)

-- 타입 레벨 증명 (컴파일 타임 검증)
data ValidList : List PracticeProblem -> Type where
  MkValid : (ps : List PracticeProblem)
         -> (isValid ps = True)  -- 증명 필요
         -> ValidList ps
```

---

## 이 프로젝트에서 사용하는 패턴

### 패턴 1: Notebook 구조 정의

```idris
-- 1단계: 기본 타입 정의
record PracticeProblem where
  constructor MkProblem
  problemNumber : Nat
  markdownIdx : CellIndex
  codeIdx : CellIndex

-- 2단계: 검증 함수 작성
isAscendingOrder : List PracticeProblem -> Bool
isAscendingOrder [] = True
isAscendingOrder [x] = True
isAscendingOrder (x :: y :: rest) =
  x.problemNumber < y.problemNumber && isAscendingOrder (y :: rest)

-- 3단계: 전체 구조 정의
record NotebookStructure where
  constructor MkNotebook
  title : CellIndex
  sections : List (CellIndex, CellIndex)  -- (markdown, code) 쌍
  practiceProblems : List PracticeProblem  -- 반드시 오름차순!

-- 4단계: 유효성 검증 함수
isNotebookValid : NotebookStructure -> Bool
isNotebookValid nb =
  isAscendingOrder nb.practiceProblems &&
  length nb.sections > 0
```

### 패턴 2: 구체적인 데이터 정의

```idris
-- 실제 노트북 구조를 Idris 코드로 표현
notebook1Structure : NotebookStructure
notebook1Structure = MkNotebook
  0                    -- title at cell 0
  [ (2, 3)            -- Section 1: markdown 2, code 3
  , (4, 5)            -- Section 2: markdown 4, code 5
  , (6, 7)            -- Section 3: markdown 6, code 7
  ]
  [ MkProblem 1 30 23  -- Problem 1
  , MkProblem 2 29 24  -- Problem 2
  , MkProblem 3 28 25  -- Problem 3
  ]
```

---

## 자주 하는 작업

### 작업 1: 새로운 노트북 구조 추가

```idris
-- 1. 새 파일 생성: idris/Domain/Notebook4Structure.idr
module Notebook4Structure

%default total

-- 2. 기존 패턴 복사 (Notebook1Structure.idr 참고)

-- 3. 구조 수정
record Notebook4Structure where
  constructor MkNotebook4
  -- 필요한 필드 추가

-- 4. 검증 함수 작성
isNotebook4Valid : Notebook4Structure -> Bool
isNotebook4Valid nb = True  -- 조건 추가

-- 5. 구체적 데이터 정의
notebook4Structure : Notebook4Structure
notebook4Structure = MkNotebook4
  -- 실제 셀 인덱스 입력
```

### 작업 2: 기존 구조 수정

```idris
-- 예: Notebook 1에 새로운 섹션 추가

-- BEFORE:
notebook1Structure = MkNotebook1
  0
  [ (2, 3), (4, 5), (6, 7) ]  -- 3개 섹션

-- AFTER:
notebook1Structure = MkNotebook1
  0
  [ (2, 3), (4, 5), (6, 7), (8, 9) ]  -- 4개 섹션 (새로 추가)
```

### 작업 3: 검증 조건 추가

```idris
-- BEFORE:
isNotebookValid nb =
  isAscendingOrder nb.practiceProblems

-- AFTER:
isNotebookValid nb =
  isAscendingOrder nb.practiceProblems &&
  length nb.sections == 10 &&           -- 새 조건
  length nb.practiceProblems >= 3       -- 새 조건
```

---

## 컴파일 에러 해결

### 에러 1: "Undefined name"

```
Error: Undefined name zip.
```

**원인**: `zip` 함수를 사용했지만 임포트 안 함
**해결**:
```idris
-- 방법 1: 사용하지 않기 (간단한 방법)
-- zip 대신 직접 구현

-- 방법 2: 임포트
import Data.List  -- zip이 포함된 모듈
```

### 에러 2: "Module name does not match"

```
Error: Module name NotebookStructure does not match file name
```

**원인**: 모듈 이름과 파일 경로가 안 맞음
**해결**:
```idris
-- 파일: idris/Domain/NotebookStructure.idr
-- 올바른 모듈 이름:
module NotebookStructure  -- ✅

-- 잘못된 모듈 이름:
module Domain.NotebookStructure  -- ❌
```

### 에러 3: "where clause" 문제

```
Error: Couldn't parse any alternatives
```

**원인**: `where` 절 문법 오류
**해결**:
```idris
-- ❌ 잘못된 사용
ConsProblem : (p1 : PracticeProblem) -> ...
           -> OrderedProblems (p1 :: ps)
  where
    helper : List PracticeProblem -> Nat
    helper [] = 0

-- ✅ 올바른 사용 (함수 밖에서 정의)
helper : List PracticeProblem -> Nat
helper [] = 0

ConsProblem : (p1 : PracticeProblem) -> ...
           -> OrderedProblems (p1 :: ps)
```

### 에러 4: Record 필드 접근

```
Error: Can't find implementation for Num (List CellIndex)
```

**원인**: 리스트에 숫자 연산 시도
**해결**:
```idris
-- ❌ 잘못됨
total = s.codeIndices + 1

-- ✅ 올바름
total = length s.codeIndices + 1
```

---

## 실전 예제

### 예제 1: 노트북 5 구조 정의하기

**요구사항**:
- 제목: cell 0
- 섹션 5개: (1,2), (3,4), (5,6), (7,8), (9,10)
- 실습 문제 5개: 순서 보장

**구현**:

```idris
module Notebook5Structure

%default total

CellIndex : Type
CellIndex = Nat

-- 실습 문제 타입
record PracticeProblem where
  constructor MkProblem
  problemNumber : Nat
  markdownIdx : CellIndex
  codeIdx : CellIndex

-- 오름차순 검증
isAscendingOrder : List PracticeProblem -> Bool
isAscendingOrder [] = True
isAscendingOrder [x] = True
isAscendingOrder (x :: y :: rest) =
  x.problemNumber < y.problemNumber && isAscendingOrder (y :: rest)

-- 노트북 5 구조
record Notebook5Structure where
  constructor MkNotebook5
  title : CellIndex
  sections : List (CellIndex, CellIndex)
  practiceHeader : CellIndex
  practiceProblems : List PracticeProblem

-- 검증 함수
isNotebook5Valid : Notebook5Structure -> Bool
isNotebook5Valid nb =
  isAscendingOrder nb.practiceProblems &&
  length nb.sections == 5 &&
  length nb.practiceProblems == 5

-- 실제 데이터
notebook5Structure : Notebook5Structure
notebook5Structure = MkNotebook5
  0                              -- title
  [(1, 2), (3, 4), (5, 6), (7, 8), (9, 10)]  -- 5 sections
  11                             -- practice header
  [ MkProblem 1 12 13
  , MkProblem 2 14 15
  , MkProblem 3 16 17
  , MkProblem 4 18 19
  , MkProblem 5 20 21
  ]
```

**컴파일 확인**:
```bash
cd idris/Domain
idris2 --check Notebook5Structure.idr
```

### 예제 2: 중복 체크 추가하기

**요구사항**: 같은 셀 인덱스가 두 번 사용되지 않도록 검증

**구현**:

```idris
-- 리스트에 중복이 있는지 확인
hasDuplicates : List CellIndex -> Bool
hasDuplicates [] = False
hasDuplicates (x :: xs) =
  if elem x xs  -- x가 xs에 있으면
  then True     -- 중복!
  else hasDuplicates xs

-- 모든 인덱스 수집
collectIndices : NotebookStructure -> List CellIndex
collectIndices nb =
  [nb.title] ++
  concatMap (\(m, c) => [m, c]) nb.sections ++
  [nb.practiceHeader] ++
  concatMap (\p => [p.markdownIdx, p.codeIdx]) nb.practiceProblems

-- 검증에 추가
isNotebookValid : NotebookStructure -> Bool
isNotebookValid nb =
  isAscendingOrder nb.practiceProblems &&
  not (hasDuplicates (collectIndices nb))  -- 중복 체크!
```

---

## 빠른 참고 치트시트

### 자주 쓰는 함수

```idris
-- 리스트
length : List a -> Nat              -- 길이
map : (a -> b) -> List a -> List b  -- 각 원소에 함수 적용
filter : (a -> Bool) -> List a -> List a  -- 조건 만족하는 것만
concatMap : (a -> List b) -> List a -> List b  -- map + concat
elem : a -> List a -> Bool          -- 포함 여부

-- 비교
(==) : a -> a -> Bool  -- 같은지
(<) : Nat -> Nat -> Bool  -- 작은지
(&&) : Bool -> Bool -> Bool  -- AND
(||) : Bool -> Bool -> Bool  -- OR
not : Bool -> Bool  -- NOT

-- Record 접근
s.fieldName  -- Record의 필드 접근
```

### 컴파일 명령어

```bash
# 타입 체크만
idris2 --check MyFile.idr

# REPL 실행
idris2 MyFile.idr
:t functionName  # 타입 확인
:doc functionName  # 문서 확인
```

---

## 학습 로드맵

1. **1주차**: 기본 문법
   - Record 정의
   - 함수 작성
   - 패턴 매칭

2. **2주차**: 리스트 처리
   - map, filter, length
   - 재귀 함수
   - 검증 함수 작성

3. **3주차**: 실전 응용
   - 기존 파일 수정
   - 새 구조 정의
   - 에러 해결

---

## 참고 자료

- [Idris 2 공식 문서](https://idris2.readthedocs.io/)
- [Type-Driven Development with Idris (책)](https://www.manning.com/books/type-driven-development-with-idris)
- 프로젝트 예제:
  - `idris/Domain/Notebook1Structure.idr` - 가장 간단
  - `idris/Domain/Notebook2Structure.idr` - 중간 복잡도
  - `idris/Domain/Notebook3Structure.idr` - 복잡한 구조

---

## 실습 문제

### 문제 1: 간단한 검증 함수
```idris
-- TODO: 실습 문제가 최소 3개 이상인지 확인하는 함수 작성
hasEnoughProblems : List PracticeProblem -> Bool
hasEnoughProblems problems = ___  -- 여기를 채우세요
```

<details>
<summary>정답</summary>

```idris
hasEnoughProblems : List PracticeProblem -> Bool
hasEnoughProblems problems = length problems >= 3
```
</details>

### 문제 2: 중복 검사
```idris
-- TODO: 리스트에서 첫 번째 중복 원소를 찾는 함수
findDuplicate : List Nat -> Maybe Nat
findDuplicate xs = ___  -- 여기를 채우세요
```

<details>
<summary>정답</summary>

```idris
findDuplicate : List Nat -> Maybe Nat
findDuplicate [] = Nothing
findDuplicate (x :: xs) =
  if elem x xs
  then Just x
  else findDuplicate xs
```
</details>

---

이 가이드를 참고하면 Idris를 직접 수정하고 관리할 수 있습니다! 🎓
