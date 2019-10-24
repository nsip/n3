curl 'http://localhost:1323/n3/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: file://' -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJkZW1vIiwiY25hbWUiOiJteVNjaG9vbCIsInVuYW1lIjoibjNEZW1vIn0.VTD8C6pwbkQ32u-vvuHnxq3xijdwNTd54JAyt1iLF3I' --data-binary '{"query":"# Write your query or mutation here\nquery fullTraversal($qspec: QueryInput!) {\n  q(qspec: $qspec) {\n    Syllabus {\n      learning_area\n      stage\n      subject\n      overview\n      courses {\n        name\n        focus\n      }\n      concepts {\n        description\n        name\n      }\n    }\n    StaffPersonal {\n      LocalId\n      RefId\n      EmploymentStatus\n    }\n    GradingAssignment {\n      DetailedDescriptionURL\n      PointsPossible\n      Description\n      TeachingGroupRefId\n      RefId\n    }\n    Subject {\n      subject\n      learning_area\n      stage\n      yrLvls\n      synonyms\n    }\n    Lesson {\n      lesson_id\n      content\n      title\n      stage\n      subject\n      teacher\n      learning_area\n    }\n    SchoolInfo {\n      StateProvinceId\n      SchoolURL\n      SchoolType\n      RefId\n      SchoolDistrict\n      LocalId\n      SchoolName\n      CommonwealthId\n      SchoolSector\n    }\n    StudentPersonal {\n      RefId\n      LocalId\n      PersonInfo {\n        Demographics {\n          BirthDate\n          IndigenousStatus\n          Sex\n        }\n      }\n    }\n    TeachingGroup {\n      SchoolYear\n      LocalId\n      LongName\n      ShortName\n      TimeTableSubjectRefId\n      RefId\n    }\n    XAPI {\n      id\n      actor {\n        mbox\n        name\n      }\n      verb {\n        id\n        display {\n          en_US\n        }\n      }\n      object {\n        id\n        definition {\n          name\n          type\n        }\n      }\n      result {\n        duration\n        success\n        completion\n        score {\n          min\n          max\n          scaled\n        }\n      }\n    }\n  }\n}\n","variables":{"qspec":{"queryType":"traversalWithId","queryValue":"A4F0069E-D3B8-4822-BDD9-4D649E2A47FD","traversal":["StaffPersonal","TeachingGroup","GradingAssignment","Property.Link","XAPI","Property.Link","Subject","Unique.Link","Syllabus","Unique.Link","Lesson"],"filters":[{"eq":["XAPI","actor.name","Albert Lombardi"]},{"eq":["TeachingGroup",".LocalId","2018-History-8-1-A"]}]}}}' --compressed



